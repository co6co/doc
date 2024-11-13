---
layout: post
title: 虚拟机安装openWrt
subtitle:
date:       2022-04-15 16:40:13
categories: [dev]
tags: [dev,虚拟机安装openWrt]
---



# 1. 新建空的linux虚拟机；
	磁盘8G
# 2. 将上一步生成的vmdk文件以磁盘的形式挂载到一个已经安装好Ubuntu64的虚拟机上，挂载好后，在Ubuntu64系统中一般是/dev/sdb；
## 2.1 下载openWRT包 [](https://archive.openwrt.org/releases/21.02.2/targets/x86/64/openwrt-21.02.2-x86-64-generic-ext4-combined.img.gz)
## 2.2  在Ubuntu 64 解压 文件 
# 3. 在ubuntu64系统上使用dd命令将OpenWrt镜像烧写到步骤2新挂载的磁盘中；
	```
		sudo dd if=openwrt-21.02.2-x86-64-generic-ext4-combined.img of=/dev/sdb
	```
	关闭Ubuntu虚拟机；
# 4. 将vmdk从Ubuntu64虚拟机解除挂载；
	
# 5. 启动新虚拟机（openWrt）。