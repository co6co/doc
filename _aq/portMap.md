---
layout: post
title: windows 端口转发
categories: [技术, 安全,windows]
tags: [ portproxy,netsh]
date: 2024-12-10 16:26:01
---

# 查看所有映射
```
netsh interface portproxy show all
```
# 增加映射
```
netsh interface portproxy add v4tov4 listenport=445 listenaddress=127.0.0.45 connectaddress=192.168.1.99 connectport=65006
```