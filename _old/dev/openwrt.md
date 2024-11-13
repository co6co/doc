---
layout: post
title: openwrt
subtitle:
date:       2023-05-25 10:56:00
categories: [dev]
tags: [dev,openwrt]
---



# 1.  系统基础
```
luci-i18n-base-zh-cn # 中文

#uname -m
x86_64

#opkg print-architecture
```

# 防火墙
 
```
iptables -t nat -I POSTROUTING -j MASQUERADE 	#旁路路由器设置
```

通过 `/etc/init.d/firwall reload` 重载防火墙(`fw3 reload` 同样操作且检查配置)

# 2. OPKG 源
web界面中就可以找到更改这两个文件的入口：**System-Software-Configure**
`opkg.conf` 用于全局
## 2.1 发行版官方源 
文件：`/etc/opkg/distfeeds.conf`
```
不建议修改
```
## 2.2 自定义源
文件：`/etc/opkg/customfeeds.conf` 
 换为中科大（清华）镜像源
- 将 `/etc/opkg/distfeeds.conf` 中的所有条目复制到 `/etc/opkg/customfeeds.conf` 中
- 将'http://downloads.openwrt.org/' 
  替换为 'https://mirrors.ustc.edu.cn/lede/' 或者 'https://mirrors.tuna.tsinghua.edu.cn/openwrt/' 即可
 
# 3. 安装包
## 3.1 安装clash
- 安装依赖：`https://github.com/vernesong/OpenClash/releases`
- 检查依赖 `opkg list-installed |grep xx`
- 安装[插件 ](https://github.com/vernesong/OpenClash/releases/download/v0.44.34-beta/luci-app-openclash_0.44.34-beta_all.ipk)
	```
	opkg install luci-app-openclash_0.44.34-beta_all.ipk #报错But that file is already provided by package  * dnsmasq
														 #opkg remove dnsmasq 即可
	```
- 安装[内核](https://github.com/vernesong/OpenClash/releases/tag/Clash)
  解压到 `/etc/openclash/core/`文件夹
  
## 3.2 磁盘
```
opkg install block-mount kmod-fs-ext4 kmod-usb-storage kmod-usb-ohci kmod-usb-uhci e2fsprogs fdisk
reboot

fdisk -l   # 查看路由器磁盘信息
mkfs.ext4 /dev/sdb # 对新增的磁盘进行格式化
```
