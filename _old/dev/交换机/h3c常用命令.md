---
layout: post
title: h3c常用命令
subtitle:
date:       2021-04-21 09:05:53
categories: [交换机]
tags: [交换机,h3c常用命令]
---


# [ACL](https://www.h3c.com/cn/d_202001/1271942_30005_0.htm#_Toc30507982)
2000～2999	报文的源IP地址
3000～3999	报文的源IP地址、目的IP地址、报文优先级、IP承载的协议类型及特性等三、四层信息
4000～4999	报文的源MAC地址、目的MAC地址、802.1p优先级、链路层协议类型等二层信息

## 指定IP段Telnet 登陆H3C设备 
```
acl number 2001
rule 0 permit source 10.248.8.0 0.0.0.255

user-interface vty 0 4	# vty0-vty-5
acl 2001 inbound
authentication-mode password 
set authentication-mode password simple 123456 
user privilege level 3   #0:参观级;1: 0要高，可以使用一些命令;2:是可以配置了;3:可以备份与删除IOS啦
```

## 交换机1口出去，只能访问192.168.1.1这个IP
```
acl number 3000
rule permit ip destination 192.168.1.1 0.0.0.0
rule deny ip 

interface gigabitethernet 1/0/1
packet filter 3000
```

# DHCP 
```
dhcp select interface （接口地址池）
dhcp select global （全局地址池）
dhcp select relay （DHCP中继）


dhcp enable

interface 端口
dhcp select interface   #（开启接口dhcp）
dhcp server dns-list xxxx


## 全局地址池
ip pool vlan20 （为vlan20创建地址池）
network xxxx mask xx
gateway-list xxxx （网关地址）
dns-list xxxx
lease day xx （租约时间）
interface 端口
dhcp select global 


## DHCP 中继
dhcp select relay （启用dhcp中继功能）
dhcp relay server-ip  xxxxx （DHCP服务器地址）
```


# tracert 第一跳 总超时
```
   ip ttl-expires enable
   ip unreachables enable
```