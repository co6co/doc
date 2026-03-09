---
layout: post
title: gpg密码破解
subtitle:
date: 2023-04-10 10:01:11
categories: [安全]
tags: [安全, gpg密码破解]
---

GPG 密码破解

# gpg2john

1. 在密钥库中找到密钥文件`secring.gpg`
2. gpg2john把它转换成john能理解的hash值

```
gpg2john ~/secring.gpg > hash
```

3. 使用JohnTheRipper 破解

```
john hash  # 尝试一些弱智密码组合
john --wordlist=wordlist.txt hash #使用字典
```
