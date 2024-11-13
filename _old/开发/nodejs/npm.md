---
layout: post
title: npm
subtitle:
date:       2021-12-14 13:39:12
categories: [nodejs]
tags: [nodejs,npm]
---


# 1.
npm install -g cnpm –registry=http://r.cnpmjs.org
或者
npm install -g cnpm –registry=https://registry.npm.taobao.org


# 2. NRM安装 
  NRM(npm registry manager )是NPM的镜像源管理工具，有时候国外资源太慢，那么我们可以用这个来切换镜像源。
```
安装NRM：
npm install nrm -g

NRM常用命令：
nrm ls：列出可选的镜像源
nrm add repository_name  repository_url：添加新的镜像源
nrm use repository_name :  切换到相应的镜像源

```