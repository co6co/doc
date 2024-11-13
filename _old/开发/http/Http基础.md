---
layout: post
title: Http基础
subtitle:
date:       2023-01-06 16:29:15
categories: [http]
tags: [http,Http基础]
---


# 1. http 
## 1.1 关键Header

# 2. 请求
```
- <request-line>(请求消息行)
- <headers>(请求消息头)
- <blank line>(空行)
- <request-body>(请求消息数据)
```

## 2.1 Content-Type
```
Content-Type: type'主类型'/subtype'子类型';parameter;
示例:Content-Type: text/html;charset:utf-8;

type'主类型'
 -text  文本类型
 -application 应用类型
 -*		所有类型
 
subtype- 子类型
- html
- xml
- json
- *


text/html ： HTML格式
text/plain ：纯文本格式      
text/xml ：  XML格式(忽略xml头所指定编码格式而默认采用us-ascii编码)
image/png： png图片格式


application/xhtml+xml ：XHTML格式
application/xml     ： XML数据格式(根据xml头指定的编码格式来编码)
application/json    ： JSON数据格式
application/octet-stream ： 二进制流数据（如常见的文件下载）




```


parameter
常见的编码方式参数charset:utf-8

## 2.2 设置Content-Type 方式
### 2.2.1 请求页面的Header 中
```
<header>
	<!--不能指定为 application/x-www-form-urlencoded和 multipart/form-data-->
	<meta content="text/html" charset="utf-8"/>
</header>
```

### 2.2.2 设置表单提交`enctype` 参数中
```
<form action enctype="multipart/form-data">发送大量文本或二进制数据时</form>

<form action enctype="application/x-www-form-urlencoded">默认方式，浏览器把表单中的数据编码为 ：key=value 的形式</form>
```
### 2.2.2 设置request header 参数中
```
var xhr= new XMLHttpRequest();
	xhr.onload=function(e){
	xhr.setRequestHeader("Content-Type","text/plain;charset=UTF-8") 
}
```
# 3. 响应



```
- <status-line>(状态行)
- <headers>(消息报头)
- <blank line>(空行)
- <response-body>(响应正文)

xhr.response="blob" #[text|decument|json|blob|arrayBuffer]
```

