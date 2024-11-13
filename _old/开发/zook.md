---
layout: post
title: zook
subtitle:
date:       2022-07-13 16:17:39
categories: [开发]
tags: [开发,zook]
---


# 1. 限制tcp使用4字命令的白名单
```
/conf/zoo.cfg
4lw.commands.whitelist=stat, srvr 

## 1.1 可以是下面得任意

conf, cons, crst, dirs, dump, envi, gtmk, ruok, stmk, srst, srvr, stat, wchc, wchp, wchs, mntr, isro, telnet close

```
# 2. ACL
```
./zkCli.sh -server 127.0.0.1:2818

#设置访问得ACL
setAcl / ip:127.0.0.1:cdrwa
setAcl /dubbo ip:127.0.0.1:cdrwa
setAcl /zookeeper ip:127.0.0.1:cdrwa

## 2.1 查看ACL 有没有设置成功
getAcl /dubbo 
```