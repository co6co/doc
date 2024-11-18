---
layout: post
title: Windows 命令行
permalink: cmd.html
categories: [技术, 安全]
tags: [https证书,java,keytool]
date: 2024-11-18 16:26:01
---

# 1. Keytool
Keytool 是一个Java 数据证书的管理工具 ,Keytool 将密钥（key）和证书（certificates）存在一个称为keystore的文件中。

在keystore里，包含两种数据：
- 密钥实体（Key entity）	->密钥（secret key）又或者是私钥和配对公钥（采用非对称加密）
- 可信任的证书实体（trusted certificate entries）->只包含公钥

# 2. 参数
```
-genkey      在用户主目录中创建一个默认文件".keystore",还会产生一个mykey的别名，mykey中包含用户的公钥、私钥和证书(在没有指定生成位置的情况下,keystore会存在用户系统默认目录，如：对于window xp系统，会生成在系统的C:\Documents and Settings\UserName\文件名为“.keystore”)
-alias       产生别名,每个keystore都关联这一个独一无二的alias，这个alias通常不区分大小写
-keystore    指定密钥库的名称(产生的各类信息将不在.keystore文件中)
-keyalg      指定密钥的算法 (如 RSA  DSA（如果不指定默认采用DSA）)
-validity    指定创建的证书有效期多少天
-keysize     指定密钥长度
-storepass   指定密钥库的密码(获取keystore信息所需的密码)
-keypass     指定别名条目的密码(私钥的密码)
-dname       指定证书拥有者信息
			 例如：  "CN=名字与姓氏,OU=组织单位名称,O=组织名称,L=城市或区域名称,ST=州或省份名称,C=单位的两字母国家代码"
-list        显示密钥库中的证书信息     
-v           显示密钥库中的证书详细信息
-export      将别名指定的证书导出到文件 
keytool -export -alias 需要导出的别名 -keystore 指定keystore -file 指定导出的证书位置及证书名称 -storepass 密码
-file        参数指定导出到文件的文件名
-delete      删除密钥库中某条目 
keytool -delete -alias 指定需删除的别名  -keystore 指定keystore  -storepass 密码     
-printcert   查看导出的证书信息
			#keytool -printcert -file yushan.crt        
-keypasswd   修改密钥库中指定条目口令   
			 keytool -keypasswd -alias 需修改的别名 -keypass 旧密码 -new  新密码  -storepass keystore密码  -keystore
-import      将已签名数字证书导入密钥库 
			 keytool -import -alias 指定导入条目的别名 -keystore 指定keystore -file 需导入的证书

下面是各选项的缺省值。
-alias "mykey"
-keyalg "DSA"
-keysize 1024
-validity 90
-keystore 用户宿主目录中名为 .keystore 的文件
-file 读时为标准输入，写时为标准输出

```

# 3. 常用操作
## 3.1 keystore的生成证书
```
keytool -genkey -alias 别名 -keypass 密码 -keyalg RSA -keysize 1024 -validity 365 -keystore D:\server.jks -storepass 123456
keytool -genkey -alias 别名 -keypass 密码 -keyalg RSA -keysize 1024 -validity 365 -keystore D:\server.jks -storepass 123456 -dname "CN=(名字与姓氏), OU=(组织单位名称), O=(组织名称), L=(城市或区域名称), ST=(州或省份名称), C=(单位的两字母国家代码)";
```
## 3.2 查看
```
 keytool -list-keystore  -keystore D:\server.jks  -storepass 123456 #  -v 查看详情
```
## 3.3 导出
```
keytool -export -alias 别名 -keystore D:\server.jks -file d:\server.crt -storepass 123456
keytool -printcert -file d:\server.crt		# 查看导出的信息
```
## 3.4 导入
```
keytool -genkey -alias 别名 -keypass 密码 -keyalg RSA -keysize 1024 -validity 365 -keystore  D:\server.jks -storepass 123456 -dname "CN=xx, OU=xx, O=xx, L=xx, ST=xx, C=xx";
keytool -export -alias 别名 -keystore D:\server.jks -file d:\server.crt -storepass 123456
```

## 3.5 删除
```
keytool -delete -alias 别名 -keystore D:\server.jks -storepass 123456
```
## 3.6 证书密码的修改
```
keytool -keypasswd -alias 别名 -keypass 密码  -new 123456(别名的新密码)  -keystore D:\server.jks -storepass 123456
```

##3.7 keystore密码的修改
```
keytool -storepasswd -keystore D:\server.jks -storepass 123456  -new 456789
```
## 3.8 修改别名
```
keytool -selfcert -alias 别名 -keypass 密码 -keystore D:\server.jks -storepass 456789 -dname "cn=yushan,ou=yushan,o=yushan,c=us"
```
