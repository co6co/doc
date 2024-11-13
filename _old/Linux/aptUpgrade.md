---
layout: post
title: aptUpgrade
subtitle:
date:       2023-06-12 16:27:21
categories: [Linux]
tags: [Linux,aptUpgrade]
---


1. 命令
```
rm -rf /etc/apt/sources.list.d		# 2020kali 对更新源的问题做了安全加固，
									#不删除会出现
									#无法安全地用该源进行更新，所以默认禁用该源的解决方法
```
2. 更新国内源 `/etc/apt/sources.list`
```
#中科大
deb http://mirrors.ustc.edu.cn/kali kali-rolling main non-free contrib
deb-src http://mirrors.ustc.edu.cn/kali kali-rolling main non-free contrib
#阿里云
deb http://mirrors.aliyun.com/kali kali-rolling main non-free contrib
deb-src http://mirrors.aliyun.com/kali kali-rolling main non-free contrib
#清华大学
deb http://mirrors.tuna.tsinghua.edu.cn/kali kali-rolling main contrib non-free
deb-src https://mirrors.tuna.tsinghua.edu.cn/kali kali-rolling main contrib non-free
#163
deb http://mirrors.163.com/debian wheezy main non-free contrib
deb-src http://mirrors.163.com/debian wheezy main non-free contrib
deb http://mirrors.163.com/debian wheezy-proposed-updates main non-free contrib
deb-src http://mirrors.163.com/debian wheezy-proposed-updates main non-free contrib
deb-src http://mirrors.163.com/debian-security wheezy/updates main non-free contrib
#东软大学
deb http://mirrors.neusoft.edu.cn/kali kali-rolling/main non-free contrib
deb-src http://mirrors.neusoft.edu.cn/kali kali-rolling/main non-free contrib
```
3. 用root 登录
4. 更新
```
apt-get update & apt-get upgrade
apt-get dist-upgrade
```
5. 删除过时
```
apt-get clean
```
6. 重启
```
reboot
```