---
layout: post
title: git
subtitle:
date:       2021-10-12 17:22:22
categories: [开发]
tags: [开发,git]
---


# git 
error:SSL certificate problem: self signed certificat
`git config --global http.sslVerify "false"`
获取
`set GIT_SSL_NO_VERIFY=true git clone`

# 多个私钥
```
ssh-keygen -t rsa -C "yourmail@gmail.com"
cat id_rsa.pub								#复制
SSH-add ~/.ssh/id_rsa						#增加私钥
ssh-add ~/.ssh/id_rsa_github
```

```
git init
git remote add origin https://gitlab.ynlbkj.com/chenyong/web.git
git pull --rebase origin master
# 清理冲突
git clean -d -fx ""
		其中
		x -----删除忽略文件已经对git来说不识别的文件
		d -----删除未被添加到git的路径中的文件
		f -----强制运行
git push -u origin master					
```
