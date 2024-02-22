---
layout: post
title: KALI Linux 升级
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
方法1：下载公钥
//查询下载 https://keys.openpgp.org/search?q=ED444FF07D8D0BF6
//44C6513A8E4FB3D30875F758ED444FF07D8D0BF6.asc
apt-key add linux_signing_key.pub

方法2：增加公钥服务器
gpg --keyserver keyserver.ubuntu.com --recv-keys ED444FF07D8D0BF6
```

```
apt-key list #查看存在的Key 
```
### 1.2.2 无法安全地用该源进行更新，所以默认禁用该源
```
E: 仓库 “http://mirrors.163.com/debian wheezy Release” 没有 Release 文件。
N: 无法安全地用该源进行更新，所以默认禁用该源。
N: 参见 apt-secure(8) 手册以了解仓库创建和用户配置方面的细节。
E: 仓库 “http://mirrors.neusoft.edu.cn/kali kali-rolling/main Release” 没有 Release 文件。
N: 无法安全地用该源进行更新，所以默认禁用该源。
N: 参见 apt-secure(8) 手册以了解仓库创建和用户配置方面的细节。
E: 仓库 “http://mirrors.163.com/debian wheezy-proposed-updates Release” 没有 Release 文件。
N: 无法安全地用该源进行更新，所以默认禁用该源。
N: 参见 apt-secure(8) 手册以了解仓库创建和用户配置方面的细节。
E: 仓库 “http://mirrors.163.com/debian-security wheezy/updates Release” 没有 Release 文件。
N: 无法安全地用该源进行更新，所以默认禁用该源。
N: 参见 apt-secure(8) 手册以了解仓库创建和用户配置方面的细节。
```
重新编辑 `sources.list` 删除多余的
```
# See https://www.kali.org/docs/general-use/kali-linux-sources-list-repositories/
#deb http://http.kali.org/kali kali-rolling main contrib non-free

# Additional line for source packages
# deb-src ht   Display information useful for debugging
#中科大
deb http://mirrors.ustc.edu.cn/kali kali-rolling main non-free contrib
deb-src http://mirrors.ustc.edu.cn/kali kali-rolling main non-free contrib
#阿里云
#deb http://mirrors.aliyun.com/kali kali-rolling main non-free contrib
#deb-src http://mirrors.aliyun.com/kali kali-rolling main non-free contrib
#清华大学
#deb http://mirrors.tuna.tsinghua.edu.cn/kali kali-rolling main contrib non-free
#deb-src https://mirrors.tuna.tsinghua.edu.cn/kali kali-rolling main contrib non-free
#163
#deb http://mirrors.163.com/debian wheezy main non-free contrib
#deb-src http://mirrors.163.com/debian wheezy main non-free contrib
#deb http://mirrors.163.com/debian wheezy-proposed-updates main non-free contrib
#deb-src http://mirrors.163.com/debian wheezy-proposed-updates main non-free contrib
#deb-src http://mirrors.163.com/debian-security wheezy/updates main non-free contrib
#东软大学
#deb http://mirrors.neusoft.edu.cn/kali kali-rolling/main non-free contrib
#deb-src http://mirrors.neusoft.edu.cn/kali kali-rolling/main non-free contrib
``` 