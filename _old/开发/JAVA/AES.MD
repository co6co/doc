---
layout: post
title: AES
subtitle:
date:       2021-05-27 15:05:11
categories: [JAVA]
tags: [JAVA,AES]
---


[key] `java.security.InvalidKeyException: Illegal key size`

JRE中自带的`local_policy.jar `、`US_export_policy.jar`是支持128位密钥的加密算法，
使用256位密钥算法，已经超出其计算范围，无法支持

# 解决方法：
1. 查看目录`/jre/lib/security/` 中有`public `, 说明 此版本为JVM启用 无限制强度管辖策略 
	- 查找文件 `java.security`

```
	crypto.policy=unlimited 	#删除前面的‘#’号
```

2. 目录中有 `local_policy.jar`，`US_export_policy.jar`
	- 去官方下载JCE无限制权限策略文件
	[jdk ](http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-java-plat-419418.html#jce_policy-1.5.0-oth-JPR)
	[jdk6](http://www.oracle.com/technetwork/java/javase/downloads/jce-6-download-429243.html)
	[JDK7](http://www.oracle.com/technetwork/java/javase/downloads/jce-7-download-432124.html)
	[JDK8 jce_policy-8.zip](http://www.oracle.com/technetwork/java/javase/downloads/jce8-download-2133166.html)

	- 覆盖
	

# 注意  

如果是开发环境 使用的是JDK  
则目录是 `C:\Program Files\Java\jdk1.8.0_131\jre\lib\security` 与生产环境`C:\Program Files\Java\jre1.8.0_131\lib\security` 目录不同