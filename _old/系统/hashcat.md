---
layout: post
title: hashcat
subtitle:
date:       2023-04-11 16:36:15
categories: [系统]
tags: [系统,hashcat]
---


# 
https://cloud.tencent.com/developer/article/1688161
支持多种计算核心
```
GPU
CPU
APU
DSP
FPGA
Coprocessor
```
```
hashcat64.exe -b //查出是否能用GPU
```

# 常见参数
```
-m, —hash-type=NUM 哈希类别，其NUM值参考其帮助信息下面的哈希类别值，其值为数字。如果不指定m值则默认指md5，例如-m 1800是sha512 Linux加密。
-a, –attack-mode=NUM 攻击模式，其值参考后面对参数。“-a 0”字典攻击，“-a 1” 组合攻击；“-a 3”掩码攻击。
-V, —version 版本信息
-h, –help 帮助信息。
–quiet 安静的模式, 抑制输出
```
# 文件
```
-o, –outfile=FILE 定义哈希文件恢复输出文件
–outfile-format=NUM 定义哈希文件输出格式，见下面的参考资料
–outfile-autohex-disable 禁止使用十六进制输出明文
-p, –separator=CHAR 为哈希列表/输出文件定义分隔符字符
–show 仅仅显示已经破解的密码
–left 仅仅显示未破解的密码
–username 忽略hash表中的用户名，对linux文件直接进行破解，不需要进行整理。
–remove 移除破解成功的hash，当hash是从文本中读取时有用，避免自己手工移除已经破解的hash
–stdout 控制台模式
–potfile-disable 不写入pot文件
–debug-mode=NUM 定义调试模式（仅通过使用规则进行混合），参见下面的参考资料
–debug-file=FILE 调试规则的输出文件（请参阅调试模式）
-e, –salt-file=FILE 定义加盐文件列表
–logfile-disable 禁止logfile
```

# 资源
```
-c, –segment-size=NUM 字典文件缓存大小（M）
-n, –threads=NUM 线程数
-s, –words-skip=NUM 跳过单词数
-l, –words-limit=NUM 限制单词数(分布式)
```
# 规则
```
-r, –rules-file=FILE 使用规则文件: -r 1.rule，
-g, –generate-rules=NUM 随机生成规则
–generate-rules-func-min= 每个随机规则最小值
–generate-rules-func-max=每个随机规则最大值
–generate-rules-seed=NUM 强制RNG种子数
```

# 自定义字符集
```
-1, –custom-charset1=CS 用户定义的字符集
-2, –custom-charset2=CS 例如:
-3, –custom-charset3=CS –custom-charset1=?dabcdef : 设置?1 为0123456789abcdef
-4, –custom-charset4=CS -2mycharset.hcchr : 设置 ?2 包含在mycharset.hcchr
```

# 攻击模式
```
–toggle-min=NUM 在字典中字母的最小值
–toggle-max=NUM 在字典中字母的最大值
–increment 使用增强模式
–increment-min=NUM 增强模式开始值
–increment-max=NUM 增强模式结束值
–perm-min=NUM 过滤比NUM数小的单词
–perm-max=NUM 过滤比NUM数大的单词
-t, –table-file=FILE 表文件
–table-min=NUM 在字典中的最小字符值
–table-max=NUM 在字典中的最大字符值
–pw-min=NUM 如果长度大于NUM，则打印候选字符
–pw-max=NUM 如果长度小于NUM，则打印候选字符
–elem-cnt-min=NUM 每个链的最小元素数
–elem-cnt-max=NUM 每个链的最大元素数
–wl-dist-len 从字典表中计算输出长度分布
–wl-max=NUM 从字典文件中加载NUM个单词，设置0禁止加载。
–case-permute 在字典中对每一个单词进行反转
```
#参考
```
1 = hash[:salt]
2 = plain 明文
3 = hash[:salt]:plain
4 = hex_plain
5 = hash[:salt]:hex_plain
6 = plain:hex_plain
7 = hash[:salt]:plain:hex_plain
8 = crackpos
9 = hash[:salt]:crackpos
10 = plain:crackpos
11 = hash[:salt]:plain:crackpos
12 = hex_plain:crackpos
13 = hash[:salt]:hex_plain:crackpos
14 = plain:hex_plain:crackpos
15 = hash[:salt]:plain:hex_plain:crackpos
```

# 调试模式输出文件
```
1 = save finding rule
2 = save original word
3 = save original word and finding rule
4 = save original word, finding rule andmodified plain
```
# 内置字符
```
l = abcdefghijklmnopqrstuvwxyz 代表小写字母
?u = ABCDEFGHIJKLMNOPQRSTUVWXYZ 代表大写字母
?d = 0123456789 代表数字
?s = !”#$%&’()*+,-./:;<=>?@[\]^_`{|}~ 代表特殊字符
?a = ?l?u?d?s 大小写数字及特殊字符的组合
?b = 0×00 – 0xff
```
# 攻击模式
```
0 = Straight （字典破解）
1 = Combination （组合破解）
2 = Toggle-Case （大小写转换）
3 = Brute-force（掩码暴力破解）
4 = Permutation（序列破解）
5 = Table-Lookup（查表破解）
6 = Hybrid dict + mask 字典加掩码破解
7 = Hybrid mask + dict 掩码+字典破解
8 = Prince（王子破解）
```

# 规则
- `?d` 代表数字
- `?l` 小写字母
- `?u` 大写字母
- `?s` 特殊字符
- `?a` 大小写字母+特殊字符
- `?2` 自定义字符串


```
`–O` 表示最优化破解模式
`-1 ?l?d`  //-1 -2 .. -4 自定义字符

```

# 破解密码规则示例
```
(1)字典攻击
-a 0 password.lst

(2)1到8位数字掩码攻击
-a 3 --increment --increment-min 1--increment-max 8 ?d?d?d?d?d?d?d?d –O 
(4)自定义字符

Hashcat.exe -a 3 –force -2 ?l?d hassh值或者hash文件 ?2?2?2?2?2?2?2?2
例如破解dz小写字母+数字混合8位密码破解：
Hashcat -m 2611 -a 3 -2 ?l?d dz.hash ?2?2?2?2?2?2?2?2

(5)字典+掩码暴力破解
Hashcat还支持一种字典加暴力的破解方法，就是在字典前后再加上暴力的字符序列，比如在字典后面加上3为数字，这种密码是很常见的。使用第六种攻击模式：
a-6 (Hybrid dict + mask)
如果是在字典前面加则使用第7中攻击模式也即( a-7 = Hybridmask + dict)，下面对字典文件加数字123进行破解：
H.exe -a 6 ffe1cb31eb084cd7a8dd1228c23617c8 password.lst ?d?d?d
假如ffe1cb31eb084cd7a8dd1228c23617c8的密码为password123，则只要password.lst包含123即可

(6)掩码+字典暴力破解
H.exe -a 7 ffe1cb31eb084cd7a8dd1228c23617c8 password.lst ?d?d?d
假如ffe1cb31eb084cd7a8dd1228c23617c8的密码为123password，则只要password.lst包含password即可。

(7)大小写转换攻击，对password.lst中的单词进行大小写转换攻击
H.exe-a 2 ffe1cb31eb084cd7a8dd1228c23617c8 password.lst


(1)8位数字破解
Hashcat64-m 9700 hash -a 3 ?d?d?d?d?d?d?d?d -w 3 –O

(2)1-8位数字破解
Hashcat-m 9700 hash -a 3 --increment --increment-min 1--increment-max 8 ?d?d?d?d?d?d?d?d

(3)1到8位小写字母破解
 Hashcat-m 9700 hash -a 3 --increment --increment-min 1--increment-max 8 ?l?l?l?l?l?l?l?l

(4)8位小写字母破解
Hashcat-m 9700 hash -a 3 ?l?l?l?l?l?l?l?l -w 3 –O

(5)1-8位大写字母破解
Hashcat-m 9700 hash -a 3 --increment --increment-min 1--increment-max 8 ?u?u?u?u?u?u?u?u

(6)8位大写字母破解
Hashcat-m 9700 hash -a 3 ?u?u?u?u?u?u?u?u -w 3 –O

(7)5位小写+ 大写+数字+特殊字符破解
Hashcat-m 9700 hash -a 3 ?b?b?b?b?b -w 3

(8)使用字典进行破解
使用password.lst字典进行暴力破解，-w 3参数是指定电力消耗
Hashcat -m 9700 -a 0 -w 3 hash password.lst
在执行破解成功后，hashcat会自动终止破解，并显示破解状态为Cracked，Recvoered中也会显示是否破解成功.
破解known_hosts中的IP地址
经过研究发现known_hosts中会对连接的IP地址进行HMAC SHA1加密，可以通过hexhosts攻击进行转换，然后通过hashcat进行暴力破解，其密码类型为160（HMAC-SHA1 (key = $salt)）。
```

```
(1)8位数字破解
Hashcat64-m 9700 hash -a 3 ?d?d?d?d?d?d?d?d -w 3 –O

(2)1-8位数字破解
Hashcat-m 9700 hash -a 3 --increment --increment-min 1--increment-max 8 ?d?d?d?d?d?d?d?d

(3)1到8位小写字母破解
 Hashcat-m 9700 hash -a 3 --increment --increment-min 1--increment-max 8 ?l?l?l?l?l?l?l?l

(4)8位小写字母破解
Hashcat-m 9700 hash -a 3 ?l?l?l?l?l?l?l?l -w 3 –O

(5)1-8位大写字母破解
Hashcat-m 9700 hash -a 3 --increment --increment-min 1--increment-max 8 ?u?u?u?u?u?u?u?u

(6)8位大写字母破解
Hashcat-m 9700 hash -a 3 ?u?u?u?u?u?u?u?u -w 3 –O

(7)5位小写+ 大写+数字+特殊字符破解
Hashcat-m 9700 hash -a 3 ?b?b?b?b?b -w 3

(8)使用字典进行破解
使用password.lst字典进行暴力破解，-w 3参数是指定电力消耗
Hashcat -m 9700 -a 0 -w 3 hash password.lst
在执行破解成功后，hashcat会自动终止破解，并显示破解状态为Cracked，Recvoered中也会显示是否破解成功.
破解known_hosts中的IP地址
经过研究发现known_hosts中会对连接的IP地址进行HMAC SHA1加密，可以通过hexhosts攻击进行转换，然后通过hashcat进行暴力破解，其密码类型为160（HMAC-SHA1 (key = $salt)）。
```

```
(1)计算HMAC SHA1值
gitclone https://github.com/persona5/hexhosts.git
cdhexhosts
gcchexhosts.c -lresolv -w -o hexhosts
./hexhosts
获取known_hosts的HMAC SHA1加密值：
注意：known_hosts值一定要正确，可以将known_hosts文件复制到hexhosts文件目录。

(2)组合攻击暴力破解
hashcat-a 1 -m 160 known_hosts.hash ips_left.txt ips_right.txt --hex-salt
组合攻击是将ips_left.txt和ips_right.txt进行组合，形成完整的IP地址进行暴力破解。

ips_left.txt和ips_right.txt文件可以用以下代码进行生成：
ip-gen.sh：
for a in `seq 0 255`
do
for b in `seq0 255`
do
echo"$a.$b." >> ips_left.txt
echo"$a.$b" >> ips_right.txt
done
done

(3)使用掩码进行攻击
hashcat -a 3 -m 160 known_hosts.hash ipv4.hcmask--hex-salt

ipv4.hcmask文件内容可在网络上下载。
破解md5加密的IP地址
在CDN等网络或者配置中往往会对IP地址进行MD5加密，由于其位数3×4+3（xxx.xxx.xxx.xxx）=17位，通过正常的密码破解其时间耗费非常长，但通过分析其IP地址的规律，发现其地址XXX均为数字，因此可以通过hashcat的组合和掩码进行攻击。
hashcat-a 1 –m 0 ip.md5.txt ips_left.txt ips_right.txt
hashcat -a1 -m 0 ip.md5.txt ipv4.hcmask
另外在F5的cookie中会对其IP地址进行加密，可以参考的破解代码如下：
import struct
cookie = "1005421066.20736.0000"
(ip,port,end)=cookie.split(".")
(a,b,c,d)=[ord(i) for i in struct.pack("i",int(ip))]
print "Decoded IP: %s %s %s %s" % (a,b,c,d)
Decoded IP: 10.130.237.59
破解技巧总结
在使用GPU模式进行破解时，可以使用-O参数自动进行优化
暴力破解一条md5值
```

```
(1)9位数字破解
Hashcat64.exe-a 3 --force d98d28ca88f9966cb3aaefebbfc8196f ?d?d?d?d?d?d?d?d?d
单独破解一条md5值需要加force参数

(2)9位字母破解
Hashcat64.exe-a 3 --force d98d28ca88f9966cb3aaefebbfc8196f ?l?l?l?l?l?l?l?l?l
破解带盐discuz密码
7位数字，7秒时间破解完成任务。
Hashcat64.exe-a 3 --force -m 2611 ffe1cb31eb084cd7a8dd1228c23617c8:f56463 ?d?d?d?d?d?d?d

8位数字破解，9秒时间破解完成任务。：
Hashcat64.exe-a 3 --force -m 2611 ffe1cb31eb084cd7a8dd1228c23617c8:f56463 ?d?d?d?d?d?d?d?d

9位数字破解，9秒时间破解完成任务。
Hashcat64.exe-a 3 --force -m 2611 ffe1cb31eb084cd7a8dd1228c23617c8:f56463 ?d?d?d?d?d?d?d?d?d

(1)6位小写字母
Hashcat64.exe-a 3 --force -m 2611 ffe1cb31eb084cd7a8dd1228c23617c8:f56463 ?l?l?l?l?l?l

(2)7位小写字母
Hashcat64.exe-a 3 --force -m 2611 ffe1cb31eb084cd7a8dd1228c23617c8:f56463 ?l?l?l?l?l?l?l

(3)8位小写字母
Hashcat64.exe-a 3 --force -m 2611 ffe1cb31eb084cd7a8dd1228c23617c8:f56463 ?l?l?l?l?l?l?l?l 9分钟左右完成破解任务

(4)9位小写字母
Hashcat64.exe-a 3 --force -m 2611 ffe1cb31eb084cd7a8dd1228c23617c8:f56463 ?l?l?l?l?l?l?l?l?l -O

字母加数字
Hashcat64.exe-a 3 --force -m 2611 -2 ?d?l ffe1cb31eb084cd7a8dd1228c23617c8:f56463?2?2?2?2?2?2?2

(3)7位大写字母
Hashcat64.exe-a 3 –force –m 2611 ffe1cb31eb084cd7a8dd1228c23617c8:f56463 ?u?u?u?u?u?u?u

(4)6到8位数字破解
Hashcat64.exe-a 3 –force –m 2611 ffe1cb31eb084cd7a8dd1228c23617c8:f56463--increment --increment-min 6 --increment-max 8 ?l?l?l?l?l?l?l?l

(1)使用数字加字母混合6位进行破解
 Hashcat64.exe-a 3 --force -m 2611 -2 ?d?l ffe1cb31eb084cd7a8dd1228c23617c8:f56463?2?2?2?2?2?2 -O

(2)使用数字加字母混合7位进行破解，破解时间4分16秒
 Hashcat64.exe-a 3 --force -m 2611 -2 ?d?l ffe1cb31eb084cd7a8dd1228c23617c8:f56463?2?2?2?2?2?2?2 –O

(3)使用数字加字母混合8位进行破解
Hashcat64.exe-a 3 --force -m 2611 -2 ?d?l ffe1cb31eb084cd7a8dd1228c23617c8:f56463?2?2?2?2?2?2?2?2 -O

字典破解模式
Hashcat64.exe-a 0 --force -m 2611 ffe1cb31eb084cd7a8dd1228c23617c8:f56463 password.lst

使用字典文件夹下的字典进行破解:
Hashcat32.exe -m 300 mysqlhashes.txt –remove -o mysql-cracked.txt ..\dictionaries\*

会话保存及恢复破解
(1)使用mask文件规则来破解密码
hashcat-m 2611 -a 3 --session mydz dz.hash masks/rockyou-7-2592000.hcmask

(2)恢复会话
hashcat--session mydz --restore

掩码破解
mask规则文件位于masks下，例如D:\PentestBox\hashcat-4.1.0\masks，执行破解设置为：
masks/8char-1l-1u-1d-1s-compliant.hcmask
masks/8char-1l-1u-1d-1s-noncompliant.hcmask
masks/rockyou-1-60.hcmask
masks/rockyou-2-1800.hcmask
masks/rockyou-3-3600.hcmask
masks/rockyou-4-43200.hcmask
masks/rockyou-5-86400.hcmask
masks/rockyou-6-864000.hcmask
masks/rockyou-7-2592000.hcmask

运用规则文件进行破解
Hashcat -m 300 mysqlhashes.txt–remove -o mysql-cracked.txt ..\dictionaries\* -r rules\best64.rule
hashcat -m 2611 -a 0 dz.hashpassword.lst -r rules\best64.rule -O
hashcat参数优化
考虑到hashcat的破解速度以及资源的分配，我们可以对一些参数进行配置

1.Workload tuning 负载调优。
该参数支持的值有1,8,40,80,160
--gpu-accel 160 可以让GPU发挥最大性能。

2.Gpu loops 负载微调
该参数支持的值的范围是8-1024（有些算法只支持到1000）。
--gpu-loops 1024 可以让GPU发挥最大性能。

3.Segment size 字典缓存大小
该参数是设置内存缓存的大小，作用是将字典放入内存缓存以加快字典破解速度，默认为32MB，可以根据自身内存情况进行设置，当然是越大越块了。 
--segment-size 512 可以提高大字典破解的速度。
LAST:密码设置建议
使用更长的字符串
使用更大的字符集字母、数字、符号
不要使用任何可能与你有关的字符作为密码或密码的一部分使用
```