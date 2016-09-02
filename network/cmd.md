#用于查看网络是否通

```
tracepath 101.201.233.95/80
```

#添加某个端口可访问 iptables

```
iptables -I INPUT 1 -p tcp --dport 10250 -j ACCEPT -m comment --comment "kubelet"

```

#查看iptables中某个链是否被使用

```
iptables -L -v
```

#将计数器清0

```
iptables -Z
```