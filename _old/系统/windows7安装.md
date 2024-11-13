---
layout: post
title: windows7安装
subtitle:
date:       2021-05-18 15:25:49
categories: [系统]
tags: [系统,windows7安装]
---


1. 提取下载的驱动包
Nvidia388.13驱动里，用压缩软件打开这个exe文件，仅提取Display.Driver文件夹，此文件夹即显卡驱动，把它解压出来

2.
Win7系统默认的USB EHCI驱动已经不支持Intel 100系主板的USB主控
官方宣布不再支持200系主板＆Win7的组合
Intel 7代酷睿和AMD的第七代Bristol Ridge APU的针对性优化也只有Win10系统能够享受得到

微软官方的Win7安装包里面并没有附带200系主板的USB驱动
预先打好Win7 USB 驱动的Win7镜像
## 1 下载 `Intel USB 3.0/3.1 eXtensible Host Controller Driver`
## 2 并提取HCSwitch和Win7 覆盖到USB3.0加载工具里面的HCSwitch和Win7文件夹
3.
`BIOS` `XHCI Hand-off` `Enable`

7代酷睿核显已经没有Win7驱动,
6代酷睿的核显以及AMD、NVIDIA独显还是有Win7驱动可以装的

4. 驱动导入安装包
Intel的官网上下载这些驱动并将其包含进入安装盘里  
使用`Dism`，可以将驱动直接打包到安装包里
```
# 查看版本
dism /get-wiminfo /wimfile:install.wim
映像的详细信息: install.wim

索引: 1
名称: Windows 7 HOMEBASIC
描述: Windows 7 HOMEBASIC
大小: 11,777,873,280 个字节

索引: 2
名称: Windows 7 HOMEPREMIUM
描述: Windows 7 HOMEPREMIUM
大小: 12,290,692,688 个字节

索引: 3
名称: Windows 7 PROFESSIONAL
描述: Windows 7 PROFESSIONAL
大小: 12,192,007,106 个字节

索引: 4
名称: Windows 7 ULTIMATE
描述: Windows 7 ULTIMATE
大小: 12,354,368,057 个字节


#1.挂载
dism /Mount-Wim /WimFile:E:\Window xits\操作系统\Windowx7\install.wim /index:4 /MountDir:mount

# 2 
dism /Get-MountedWimInfo

安装目录: E:\Window xits\操作系统\Windowx7\Mount
映像文件: E:\Window xits\操作系统\Windowx7\install.wim
映像索引: 4
安装的读/写: 是
状态: 确定

# 3.增加驱动（导入驱动 ）
dism /image:mount /add-driver /driver:驱动\ /Recurse
#如果驱动程序没有进行签名 forceunsigned

# 4.导出驱动 
dism /online /export-driver /destination:D:\driver\
 

dism /Unmount-Wim /mountdir:mount /commit	# 使用参数/Commit，放弃更改/Discard

```



5. 核显驱动安装
安装最新的集显驱动的时候：
修改inf文件，照猫画虎，将Win10的节复制一份到Win7节中。不过修改inf后会导致签名不对.
Win7可以选择继续，Win8.1就要关闭驱动签名验证才行

6. windows 更新
windows update   --> Unsupported hardware
它会告诉欺骗检查程序 https://github.com/zeffy/wufuc
 