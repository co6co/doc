---
layout: post
title: yran
subtitle:
date:       2022-10-19 10:34:56
categories: [nodejs]
tags: [nodejs,yran]
---



# 查看目录
```
yarn global bin  #查看Bin 所在目录
yran global dir  #查看全局安装目录
yran cache dir 	 #查看全局缓存位置
```
## 修改目录
```
yarn config set prefix "D:\Yarn\data"  #改变yarn 全局Bin位置
yarn config set prefix global-folder "D:\Yarn\data\global"  #改变yarn 全局安装目录
yarn config set prefix cache-folder "D:\Yarn\data\cache"  #改变yarn 全局安装Cache目录
yarn config set prefix link-folder "D:\Yarn\data\link"  #改变yarn 全局安装link目录


```