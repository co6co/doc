---
layout: post
title: svchost
subtitle:
date:       2021-09-16 09:00:22
categories: [系统]
tags: [系统,svchost]
---


[DOC](svchost.exe)
# 1. 概述
从`动态链接库 (DLL)` 中运行的服务的通用主机进程名称

# 2. 服务
start 参数：
`0`，则驱动由启动引导器加载，应该跟“随着开机，最先启动”是同一回事；
`1`，则驱动由操作系统的I/O子系统加载，即在系统内核初始化时加载；
`2`，则驱动/服务在启动后自动加载；
`3`，则驱动/服务就是按需手动加载；
`4`，驱动/服务就是被禁用的状态，新系统禁用服务还需设置`UserServiceFlags`为`0`

## 2.1 windows 2000
一般有2个svchost进程，
	- RPCSS（Remote Procedure Call）服务进程
	- 很多服务共享的一个svchost.exe
	

## 2.2 Windows XP
4个以上的svchost.exe服务进程
Windows 7中一般是6个

## 2.3 Windows 10操作系统
不再使多个服务共享1个svchost.exe进程，
而会为`每个服务`都分配一个独立的svchost.exe进程。
因此在更新到最新版Windows 10后，在任务管理器中可以看到80至90个svchost.exe进程

## 2.4 服务路径
查看服务路径：录入rpcss服务的可执行文件的路径为`c:\windows\system32\svchost.exe -k rpcss`，
说明rpcss服务是依靠svchost调用“rpcss”参数来实现的，而参数的内容则是存放在系统注册表中的`parameters\ServiceDll`。

在启动的时候，Svchost.exe检查注册表中的位置(`HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SvcHost`)
来构建需要加载的服务列表。这就会使多个Svchost.exe在同一时间运行。


`{4D36E972-E325-11CE-BFC1-08002BE10318}` 网卡相关


## 