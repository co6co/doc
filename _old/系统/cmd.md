---
layout: post
title: cmd
subtitle:
date:       2021-08-18 10:47:37
categories: [系统]
tags: [系统,cmd]
---


# 
chkdsk c：/f 	# 检查c盘
sfc /scannow /offbootdir =C:\ /offwindir =C:\Windows\  #修复C
 1. 有一个系统修复处于挂起状态，需要重新启动才能完成该修复。重新启动Windows并再次运行sfc
 解决：删除`C:\Windows\winsxs`下的`pending.xml`和`reboot.xml`文件，重启后再次运行SFC即解决问题。
# 