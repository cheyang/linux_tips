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
iptables -nvL 
iptables -t nat -nvL
```

#将计数器清0

```
iptables -Z
```

#添加debug信息：

```
for c in PREROUTING OUTPUT; do iptables -t nat -I $c -d 10.116.0.2 -j LOG --log-prefix "DBG@$c: "; done
for c in PREROUTING OUTPUT POSTROUTING; do iptables -t nat -I $c -d 10.116.160.7 -j LOG --log-prefix "DBG@$c: "; done
for c in PREROUTING OUTPUT POSTROUTING; do iptables -t nat -I $c -d 10.116.0.2 -j LOG --log-prefix "DBG@$c: "; done
```

#在查看dmesg

```
dmesg | tail
```

#保存iptables配置

```
iptables-save >/etc/iptables.up.rules
```

#恢复iptables的配置

```
iptables-restore >/etc/iptables.up.rules
```