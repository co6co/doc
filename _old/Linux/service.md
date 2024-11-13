---
layout: post
title: service
subtitle:
date:       2022-04-12 11:23:23
categories: [Linux]
tags: [Linux,service]
---


# 查看服务列表
```
systemctl list-unit-files --type=service  
service mysqld.service restart
systemctl daemon-reload    --- list-unit-files 有但是无法显示未找到,重新载入
 



```
## 加入开机启动项/启动mysql进程
centos7中服务不在是用`service`这个命令来启动与停止，
也不再用`chkconfig`来设置开机启动与否
```

systemctl enable mysqld.service
systemctl start mysqld.service

“/usr/lib/systemd/”
‘/usr/lib/systemd/system’ 有系统（system）和用户（user）之分，像需要开机不登陆就能运行的程序
每一个服务以.service结尾，一般会分为3部分：[Unit]、[Service]和[Install]
```


# 防火墙
```
##/etc/sysconfig/iptables
-A INPUT -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT

systemctl enable iptables.service
systemctl start iptables.service

```

## mysql

```
/etc/init.d/mysqld start 
`vi /etc/my.cnf` mysql 错误日志位置 

//Can't create/write to file '/mysql_data/tmp/ibXafr1c'
chown -R mysql:mysql tmp/    //chown mysql.mysql /var/run/mysqld/
chmod 777 -R tmp/


//Unit mysqld.service could not be found.
//找到mysql.server文件，这个文件据说与mysqld文件一模一样，只是文件名不同
[]$ find / -name mysql.server
[]$ cp mysql.server /etc/init.d/mysqld





1.安装:
### maria DB如同 MySQL 的影子版本，玛莉亚数据库是 MySQL 的一个分支版本（branch）
yum install -y mariadb-server
2.启动maria DB服务:
systemctl start mariadb.service  #CentOS 7.x开始，CentOS开始使用systemd服务来代替daemon，原来管理系统启动和管理系统服务的相关命令全部由systemctl命令来代替

 
## 下载mariadb的依赖包 Failed to start mariadb.service: Unit not found
yum install mariadb-embedded mariadb-libs mariadb-bench mariadb mariadb-sever

```

```
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
User=mysql
Group=mysql
ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf
LimitNOFILE= 5000
#Restart=on-failure#RestartPreventExitStatus=1#PrivateTmp=false
```

mysql 启动方式
```
 bin/mysqld --defaults-file=/etc/my.cnf  &
 mysqld_safe --defaluts-file=/etc/my.cnf &         #相当于多了一个守护进程,mysqld挂了会自动把mysqld进程拉起
```