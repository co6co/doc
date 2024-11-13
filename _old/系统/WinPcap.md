---
layout: post
title: WinPcap
subtitle:
date:       2021-10-13 15:22:18
categories: [系统]
tags: [系统,WinPcap]
---


# 概述

1. WinPcap：目前最新的版本是 4.1.3，它兼容于 NDIS 5.x driver model。
2. Win10Pcap：目前最新的版本是 10.2.5002，它兼容于 NDIS 6.x driver model。

SDK 都是一样的。

Windows 7 及以上版本，可以装 Win10Pcap；否则，建议装 WinPcap。
主语：虽然 Win10Pcap 的名字是 Win10，但是它实际上兼容于 Win7、Win8/8.1、Win10。


# Npcap
`C:\Program Files\Npcap`   是在WinPcap的基础上进行优化开发的，可以抓取本地数据(Nmap 使用)

NDIS		system32\drivers\ndis.sys		系统文件
npf							  npf.sys		系统文件


#　WinPcap 相关文件
```
C:\Windows\system32\wpcap.dll
C:\Windows\system32\Packet.dll
C:\Windows\system32\WanPacket.dll
C:\Windows\system32\pthreadVC.dll
C:\Windows\system32\drivers\npf.sys


C:\Windows\SysWOW64\wpcap.dll
C:\Windows\SysWOW64\Packet.dll
C:\Windows\SysWOW64\WanPacket.dll
C:\Windows\SysWOW64\pthreadVC.dll
C:\Windows\System32\drivers\npf.sys

```


`tasklist /m packet.dll` 查看占用该模块的进程信息


#重置Windows 权限
`icacls * /t /q /c /reset`
	t-对当前目录及其子目录中的所有指定文件进行操作。
	q-禁止显示成功消息。
	c-尽管有任何文件错误，仍继续操作。错误消息仍将显示。

`secedit /configure /cfg %windir%\inf\defltbase.inf /db defltbase.sdb /verbose`
