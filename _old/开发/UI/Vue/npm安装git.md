---
layout: post
title: npm安装git
subtitle:
date:       2023-01-17 17:25:50
categories: [Vue]
tags: [Vue,npm安装git]
---


# 1. 通过用户名安装
```bash
# 直接利用用户名和仓库名进行安装
npm install sunxiaochuan/koatest
# 也可以在前面加上 github 前缀
npm install github:sunxiaochuan/koatest

```

## 2. 通过地址安装
```
# 直接通过 git 上项目的地址进行安装
npm install git+https://github.com/sunxiaochuan/koatest.git
# 或者以 ssh 的方式
npm install git+ssh://github.com/sunxiaochuan/koatest.git
```