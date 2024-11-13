---
layout: post
title: MSF
subtitle:
date:       2021-04-22 09:21:21
categories: [安全]
tags: [安全,MSF]
---


# Metasploit Framework  简称 MSF
msf中有很多漏洞利用exp与payload

## Exploit 渗透
## Payload 期望目标被 Exploit 后 执行代码
## Shellcode 是在渗透攻击是作为攻击载荷运行的一组机器指令，通常用汇编语言编写。
## Module 用于发起 Exploit 攻击或执行某些辅助攻击动作
## Listener 用于等待网络连接的组件
## Post 后渗透攻击模块		在渗透测试成功后，进一步的收集目标系统的信息，为进一步深入目标系统做准备
## Encoders 编码模块	将攻击代码进行编码，编译，来绕过杀毒软件的检测

## 相关命令
```
# service postgresql start				#开启数据库
# msfdb init							#初始化数据库 第一次使用
# msfconsole							#启动MSF终端
```
````
msf> db_status							#查看数据状态
msf> show payloads 						#查看所有payloads 模块
msf> search scanner		
msf> search MS08-067					#搜索模块信息
msf> explit/windows/smb/ms08_067_netapi	#1.配置模块
msf> show options
msf> back 								#返回上一级
msf> background 						#将当前操作在后台运行
msf> use 								#使用所选模块
msf> set 								#设置选项
msf> unset 								#取消设置
msf>
````

```
~use auxiliary/scanner/smb/smb_ms17_010			#选择模块
~show options									#查看选项（有选项是yes的需要设置）
~info											#查看详细（和show options功能类似）
~service										#数据库的内容
~set rhosts 192.168.1.129						#设置选项（有的需要设置多个选项）
~run											#开始运行

```
## service
```
service 										#列出所有
service -p 80									#过滤 by 端口
service -s serviceName [http|ftp|...]			#过滤 by 服务名
service -S keyName								#过滤 by 字符串
service -R 										#set RHOST 可过滤后再加
service -c name,port							#显示指定列名
```

# 更新
```
root@kali:~# apt remove metasploit-framework
root@kali:~# sudo rm /var/cache/apt/archives/lock
root@kali:~# curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && chmod 755 msfinstall && ./msfinstall
```