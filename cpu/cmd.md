＃ 用于分析cpu的命令

| 命令      |    描述          | 
| :-------- | ---------------:| 
| uptime    | 平均负载         | 
| vmstat    | cpu的平均负载    | 
| mpstat    | 单个cpu的统计信息 |
| pidstat   | 每个进程cpu用量 | 

1. uptime

```
$uptime
 20:38:16 up 18 days, 20:08,  4 users,  load average: 0.07, 0.04, 0.05
```

```
$last -10
root     pts/5        10.2.224.170     Thu Aug 11 20:34   still logged in
root     pts/4        10.2.224.116     Thu Aug 11 19:21   still logged in
root     pts/3        10.2.224.116     Thu Aug 11 19:11   still logged in
root     pts/0        10.2.224.116     Thu Aug 11 19:11   still logged in
root     pts/3        10.2.224.116     Thu Aug 11 18:43 - 18:43  (00:00)
root     pts/0        10.2.224.116     Thu Aug 11 18:37 - 19:11  (00:33)
```

2\. vmstat

3\. mpstat


4\. pidstat

4.1 进程（线程）switch context的排序

```
$pidstat -wt| sort -gr -k 6 | head -10
07:48:39 PM   108         -       950     20.13      0.00  |__java
07:48:39 PM   108         -      1003      4.39      0.00  |__java
07:48:39 PM     0         -       810      4.05      0.00  |__docker
07:48:39 PM   108         -      1001      2.42      0.89  |__java
07:48:39 PM   108         -       961      2.19      3.95  |__java
07:48:39 PM   108         -      1041      1.42      0.00  |__java
07:48:39 PM     0         7         -      1.42      0.00  rcu_sched
07:48:39 PM     0         -         7      1.42      0.00  |__rcu_sched
07:48:39 PM     0         -       927      1.26      0.00  |__mesos-master
07:48:39 PM     0         -       926      1.26      0.00  |__mesos-master
```

4.2 当前写disk

```
$pidstat -d | sort -nr -k 6 | head -10
07:51:24 PM     0       519      0.06      0.28      0.00     346  sshd
07:51:24 PM     0         1      0.06      0.14      0.00     724  systemd
07:51:24 PM   108       592      0.02      0.41      0.00     306  java
07:51:24 PM     0       799      0.02      1.24      0.51     737  docker
07:51:24 PM     0       510      0.02      0.04      0.01      69  cron
07:51:24 PM     0       506      0.02      0.00      0.00     949  mesos-master
07:51:24 PM     0       939      0.01      0.96      0.51     117  docker-containe
07:51:24 PM     0       171      0.01      0.00      0.00      77  systemd-udevd
```

5\. lscpu

```
lscpu
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                8
On-line CPU(s) list:   0-7
Thread(s) per core:    1
Core(s) per socket:    1
座：                 8
NUMA 节点：         1
厂商 ID：           GenuineIntel
CPU 系列：          6
型号：              44
型号名称：        Intel(R) Xeon(R) CPU           E5620  @ 2.40GHz
步进：              2
CPU MHz：             2400.144
BogoMIPS：            5067.36
超管理器厂商：  Microsoft
虚拟化类型：     完全
L1d 缓存：          32K
L1i 缓存：          32K
L2 缓存：           256K
L3 缓存：           12288K
NUMA 节点0 CPU：    0-7
```