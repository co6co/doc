---
layout: post
title: KALI Linux 升级
subtitle: 
description: 
header-img: 
date:       2023-7-25 15:02:01
---

# 1. Linux升级
## 1.1 查看版本
```
grep VERSION /etc/os-relese
```

## 1.2 更新
```
apt upgrade && apt full-upgrade
```
### 1.2.1 无法安全地用该源进行更新，
#### 1.2.1.1 已知的几个 Key Server
[Ubuntu Key Server](https://keyserver.ubuntu.com/)
[Debian Public Key Server](https://keyring.debian.org/)
[Open PGP Key Server](https://keys.openpgp.org/)

下载相关 Key:
在 上面的网址查询Key在哪， keyserver 选择对应的网址
```
apt-key add linux_signing_key.pub
gpg --keyserver keyserver.ubuntu.com --recv-keys kkkkkkkkkkkkk
```

```
apt-key list #查看存在的Key
```