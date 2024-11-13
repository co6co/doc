---
layout: post
title: HP LoadRunner
subtitle:
date:       2022-11-18 10:33:02
categories: [单元测试]
tags: [单元测试,HP LoadRunner]
---


#工具说明
```
Virtual User Generator    虚拟用户生成器
LoadRunner Controller     创建、运行和监控场景
LoadRunner Analysis       分析测试结果
```

1. 启动`HP WebTours`服务器
```
Could not reliably determine the server's fully qualified domain name
```
第一次启动需要配置 HP\LoadRunner\WebTours\conf\
```
ServerName localhost:1080  # 移除ServerName 前面的#
```

2. 启动`HP Web Tours Application`
	可登录用户名和密码
3. 录制脚本

	启动Virtual User Generator
	File>新建脚本和解决方案(CTRL +N)
	Web-HTTP/HTML >>输入脚本名和位置>> 创建（空脚本）
	
	录制脚本：
	CTRL+R> 弹框中填入URL
	录制选项>URL-base-script>URL Advanced > create 【去勾】
	开始录制
	
	