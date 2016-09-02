# Swarmd的启动
=====================

## 概述

Swarmkit有两个核心的执行程序：swarmd和swarmctl。swarmd逻辑上代表了cluster中的一个node，角色既可以是Manager也可以是Agent，这由启动参数决定。swarmd作为后台程序运行在cluster中的每台机上，彼此互相通信，成为整个cluster中的基础架构。而swarmctl则是向作为命令行工具，对整个cluster发号施令。下面我们就swarmd的启动过程和关键代码进行解读。

### 启动过程

swarmd进程的入口源码在：`github.com/docker/swarmkit/cmd/swarmctl/swarmd/main.go`

实际上，swarmd本身对于命令行处理利用的是开源项目 github.com/spf13/cobra， 对于corba我最深刻的印象就是下面这段话

>Commands represent actions, Args are things and Flags are modifiers for those actions.

Command代表行为，Args代表行为实施的对象，Flags代表对于行为的修饰。 就比如'ls -a /'，表示显示根目录包含隐藏文件的所有文件， 而'ls -R /'递归显示

另外，k8s的命令行有的也是这个类库。我个人认为使用corba而非golang的标准库的原因有两点：
* 在于其可以比较模块化的处理常见的sub command
* 类似一些智能提示的语法糖


入口函数的逻辑非常简单，实际上就是调用｀mainCmd.Execute()｀

```go
func main() {
	if err := mainCmd.Execute(); err != nil {
		log.L.Fatal(err)
	}
}
```

而在`mainCmd`的结构体定义中，最重要的就是RunE对应的方法,在mainCmd调用main函数中Execute方法时就回调了RunE方法。可以说它就是swarmd中真正的‘main函数’

```go
mainCmd = &cobra.Command{
		Use:          os.Args[0],
		Short:        "Run a swarm control process",
		SilenceUsage: true,
		PersistentPreRun: func(cmd *cobra.Command, _ []string) {
			...
		},
		RunE: func(cmd *cobra.Command, args []string) error {
			ctx := context.Background()
			hostname, err := cmd.Flags().GetString("hostname")
			if err != nil {
				return err
			}
			addr, err := cmd.Flags().GetString("listen-remote-api")
			if err != nil {
				return err
			}
```

而RunE中的代码做了如下工作：  
(1) 初始化一个全局的的根context（root）, context是google官方提供处理并发的类库，它可以定义由一个请求衍生出的各个goroutine之间需要满足一定的约束关系，以实现一些当根请求结束后，就可以中止与其相关goroutine的功能，同时也可以传递请求全局变量。后面会结合本程序进行详细讲解。
```go
ctx := context.Background()
```
如果看过`golang.org/x/net/context`的实现，就能知道作为根context，ctx是空的，无法传递值也无法被取消的。

(2) 解析swarmd启动时需要的参数

| 参数        |    描述          |   默认值  | 
| :----------| :---------------:| --------:|
| version，v   | 显示版本号        | false    |
| log-level, l| 日志级别，包括debug,info, warn, error, fatal    | info|
| state-dir,d | 保存状态的文件 | ./swarmkitstate |
| join-token  | the secret token required to join the cluster | |
| version，v  | 显示版本号        | false    |
| engine-addr| docker engine的访问地址    | unix:///var/run/docker.sock|
| listen-remote-api| 当swarmd监听的端口 | 0.0.0.0:4242 |
| listen-control-api   | 每个进程cpu用量 | 

(3) 根据步骤（1）中的空context初始化可cancel的子context，并且产生cancel函数，该cancel函数会在RunEx方法退出前调用。

```go
ctx, cancel := context.WithCancel(ctx)
defer cancel()
```
在这里，WithCancel方法做了两件事情：  
a. 根据当前的context创建子context，并且如果当前的context是可以被cancel掉的话  
b. 创建了一个channel ｀done chan struct{}｀，并将这个channel传给了cancel函数。在后面我们会经常看到如下的方法调用

```go
case <-ctx.Done():
	return
```

它的目的是当ctx结束的时候，该方法所在gorouting就会退出，并释放资源。而cancel函数所做的事情恰恰是标明ctx结束

```go
close(done)
```
可以说context在swarmd中被广泛的使用，这里只是埋下了伏笔。

(4) 根据docker-engine-addr初始化Executor，而实际上目前executor就是docker engine的GRPC客户端。我们知道，swarmd号称自己可以支持插件化的executor，但就目前的实现来说，完全实现一个和docker engine一致的grpc server还是很麻烦的,自定义的executor还并不现实。个人觉得它的executor与agent通信的接口还不够通用。

```go
            engineAddr, err := cmd.Flags().GetString("engine-addr")
			if err != nil {
				return err
			}

            client, err := engineapi.NewClient(engineAddr, "", nil, nil)
			if err != nil {
				return err
			}

           executor := container.NewExecutor(client)
```

(5) 根据用户输入的参数创建Node对象，并且通过Start启动Node内部中Manager或者agent。可以注意到ctx作为参数传递给Node对象。

```go
n, err := agent.NewNode(&agent.NodeConfig{
				Hostname:         hostname,
				ForceNewCluster:  forceNewCluster,
				ListenControlAPI: unix,
				ListenRemoteAPI:  addr,
				JoinAddr:         managerAddr,
				StateDir:         stateDir,
				JoinToken:        joinToken,
				ExternalCAs:      externalCAOpt.Value(),
				Executor:         executor,
				HeartbeatTick:    hb,
				ElectionTick:     election,
			})
			if err != nil {
				return err
			}

			if err := n.Start(ctx); err != nil {
				return err
			}
```

以下为Node的Start函数的实现，可以看到它利用golang里面的once类型来保证全局的唯一性操作，在整个操作中，首先就会利用`close(n.started)`把Noee.started这个`Channel`关掉，接着开始启动节点的初始化过程：`go n.run(ctx)`。我们会在下一篇文章中详细接受Node的具体实现。
```go
func (n *Node) Start(ctx context.Context) error {
	err := errNodeStarted

	n.startOnce.Do(func() {
		close(n.started)
		go n.run(ctx)
		err = nil // clear error above, only once.
	})

	return err
}
```

(6) 设置swarmd的信号捕捉，启动OS.Signal channel接收SIGINT信号，

```go
            c := make(chan os.Signal, 1)
			signal.Notify(c, os.Interrupt)
			go func() {
				<-c
				n.Stop(ctx)
			}()

```

(6.1) 创建并设置一个Channel c，用于接收系统信号
(6.2) 通过signal.Notify(c, os.Interrupt)中的Notify函数来实现将接收的signal信号传递给Channel c。在swarmd中，仅接受SIGINT 3的信号,也就是通过`kill -3`或者`Ctrl+c`可以正常退出swarmd程序。
(6.3) 创建一个gorouting来处理Interrupt信号， 当信号类型为SIGINT时，就会执行Node的Stop方法

(7) 启动一个新的gorouting输出“Node is Ready”
```go
  go func() {
				select {
				case <-n.Ready():
				case <-ctx.Done():
				}
				if ctx.Err() == nil {
					logrus.Info("node is ready")
				}
			}()

```
`Node.Ready()`会返回`Node.ready`这个`Channel`


(8) 当Node初始化完成后, RunE方法一直就会等待在Node的Err函数里，我们可以看到只有用户的中断和context的cancel才会让swarmd退出

```go
func (n *Node) Err(ctx context.Context) error {
	select {
	case <-n.closed:
		return n.err
	case <-ctx.Done():
		return ctx.Err()
	}
}
```