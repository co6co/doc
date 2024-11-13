---
layout: post
title: john
subtitle:
date:       2023-07-18 14:35:34
categories: [安全]
tags: [安全,john]
---


 
# 命令
```
$ echo -n "password" | md5sum
# john --wordlist=dict.txt --format=md5 hashes.txt 

//暴力  
# john --incremental hashes.txt    #尝试所有可能的密码组合的攻击方法

//规则
//应用一些规则来生成可能的密码组合
# john --wordlist=dict.txt --rule=all hashes.txt #则来生成密码组合，并尝试破解哈希值
```

