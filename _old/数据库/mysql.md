---
layout: post
title: mysql
subtitle:
date:       2021-08-31 11:42:10
categories: [数据库]
tags: [数据库,mysql]
---


# 安装服务：
`C:\Program Files\MySQL\MySQL Server 5.6\bin>mysqld --install "mysql56" --defaults-file="C:/ProgramData/MySQL/MySQL Server 5.6/my.ini"`

# mysql zip安装
## 1. 设置环境变量 `C:/mysql/bin`
## 2. `C:/mysql/`创建配置文件
```
[mysql]
default-character-set=utf8
[mysqld]
# 设置3306端口
port = 3306
# 设置mysql的安装目录
basedir = C:\\web_soft\\mysql-8.0.17-winx64\\
# 设置mysql数据库的数据的存放目录
datadir = C:\\web_soft\\mysql-8.0.17-winx64\\data
# 允许最大连接数
max_connections=20
# 服务端使用的字符集默认为8比特编码的latin1字符集
character-set-server=utf8
# 创建新表时将使用的默认存储引擎
default-storage-engine=INNODB
# 创建模式
sql_mode = NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
```
## 3.  `mysqld --initialize-insecure` 初始化data目录
## 4. 安装mysql服务
```
mysqld --install

#其他相关
mysqld –initialize-insecure自动生成无密码的root用户；
mysqld –initialize自动生成带随机密码的root用户；
mysqld -remove移除自己的mysqld服务；
net stop mysql命令，停止mysql服务
```
## 5. 启动mysql服务
```
net start mysql
```

# mysql 使用
```
mysql -u root -p

use mysql;
#在MySQL 5.7.9以后废弃了password字段和password()函数
#1.root用户authentication_string字段下有内容
updata user set authentication_string='' where user='root' 
#2. 使用ALTER修改root用户密码,方法为：
alter user 'root'@'localhost' IDENTIFIED by '新密码'；
Flush Privileges;
```