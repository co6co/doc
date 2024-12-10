---
layout: post
title: vsftpd
permalink:  
categories: [工具]
tags: [ftp,vsftpd]
date: 2024-12-10 16:26:01
---
# 1. 增加用户
```
sudo adduser ftpuser
或者
sudo useradd -m ftpuser
sudo passwd ftpuser
```
# 2. 设置home 目录
```
#设置用户home目录
sudo useradd -d /srv/ftp/ftpuser -m ftpuser
```
# 2. 权限
```
# 修改权限
sudo chown ftpuser:ftpuser /srv/ftp/ftpuser
sudo chmod 755 /srv/ftp/ftpuser

# 重启服务
sudo systemctl restart vsftpd
sudo service vsftpd restart
```

# 其他
```
如果你的系统启用了 SELinux，你可能还需要调整 SELinux 策略以允许 FTP 访问。可以使用 setsebool 命令来设置布尔值，例如：
sudo setsebool -P ftp_home_dir on
```