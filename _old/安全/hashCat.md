---
layout: post
title: hashCat
subtitle:
date:       2023-07-18 14:35:34
categories: [安全]
tags: [安全,hashcat]
---
# 1.　hashcat简介 
按s键查看破解进度，`p`键暂停，`r`键继续破解，`q`键退出破解
## 1.1 hashcat常用命令
```
-m 指定哈希类型
-a 指定破解模式
-V 查看版本信息
-o 将输出结果储存到指定文件
--force 忽略警告
--show 仅显示破解的hash密码和对应的明文
--remove 从源文件中删除破解成功的hash
--username 忽略 hash表中的用户名
-b 测试计算机破解速度和相关硬件信息
-O 限制密码长度
-T 设置线程数
-r 使用规则文件
-1 自定义字符集 -1 0123asd ?1={0123asd}
-2 自定义字符集 -2 0123asd ?2={0123asd}
-3 自定义字符集 -3 0123asd ?3={0123asd}
-i 启用增量破解模式
--increment-min 设置密码最小长度
--increment-max 设置密码最大长度
```

## 1.2 hashcat破解模式介绍
```
0    straight                                字典破解
1    combination                             将字典中密码进行组合（1 2>11 22 12 21）
3    brute-force                             使用指定掩码破解
6    Hybrid Wordlist + Mask                  字典+掩码破解
7    Hybrid Mask  + Wordlist                 掩码+字典破解
```
## 1.3 hashcat集成的字符集
```
?l              代表小写字母
?u              代表大写字母
?d              代表数字
?s              代表特殊字符
?a              代表大小写字母、数字以及特殊字符  
?b              0x00-0xff 
```

# 2. 常见命令
```
hashcat -m 1800 -a 0 -o found.txt crack.hash rockyou.txt
hashcat  -a 0 hashXXXXXXXXXXXXXXXXXXXX  password.txt  --force
hashcat  -a 3 hashXXXXXXXXXXXXXXXXXXXX  ?l?l?l?l --force
#使用字典+掩码
hashcat  -a 6  hashXXXXXXXXXXXXXXXXXXXX  password.txt  ?d?d?d --force
#使用掩码+字典
hashcat  -a 7  hashXXXXXXXXXXXXXXXXXXXX  ?d?d password.txt   --force
# mysql
hashcat -a 3 -m 300 --force hashXXXXXXXXXXXXXXXXXXXX ?d?d?d?d?d?d
# office
python office2john.py xxx.docx # 结果 文件名:$office$*2013*100000*256*16*3232XXXXXXXXXXXXXXXXXXXXXXXXXXXXX*32XXXXXXXXXXXXXXXXXXXXXXx*64XXXXXXXXXXXXXXXXXXXXXXXXXXXX
hashcat -a 3 -m 9600 $office$*2013*100000*256*16*3232XXXXXXXXXXXXXXXXXXXXXXXXXXXXX*32XXXXXXXXXXXXXXXXXXXXXXx*64XXXXXXXXXXXXXXXXXXXXXXXXXXXX --force ?d?d?d?d?d?d


```

# 3. John the ripper
获取文件的密文值
```
rar2john.exe Python_glxtym.rar


```

## 3.1 Windows 密码解密
LM Hash 是一种 Windows 系统身份认证协议，在 Windows 7 或 Windows 2008 之前的系统使用，之后的系统默认禁用了 LM Hash 协议认证，使用 ntlm hash 的方式。
，Windows 密码进行破解建议使用高版本的 hashcat 软件，4.1.0及以下的版本会因各种问题提前终止
最新的 hashcat-6.2.6
- LM Hash ：对应 hashcat 中的类型编号为 3000
- ntlm hash：对应 hashcat 中的类型编号为 1000

## 3.2 linux
格式：`$id$salt$encrypted`
``` 
test:$6$f0EotKbw$sLAujh0EleiXNAuoph20iL517cXlcExWLATwz3xgCEyYlsIECUa9nuDdiT5/ntWfJDfxFhYGcMknkCq5Awgf20:15118:0:99999:7:::
```
- id
```
1->MD5 
5->SHA-256 
6->SHA-512
```
- encrypted`
运算方法 hash("passwd＋salt")后，再经过编码

-- test 是用户名
-- $6$  是表示一种类型标记为6的密码散列suans fa,这里指SHA-512哈希算法.
-- f0EotKbw 加盐(Salt)值


