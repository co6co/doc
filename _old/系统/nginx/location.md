---
layout: post
title: location
subtitle:
date:       2021-05-28 13:19:20
categories: [nginx]
tags: [nginx,location]
---


# location 匹配规则
(=) > (完整路径) > (^~ 路径) > (~,~* 正则顺序) > (部分起始路径) > (/)
##　说明：
- `^~`			 以某个常规字符串开头，不是正则匹配;
- `~` 			区分大小写的正则匹配;
- `~*` 			不区分大小写的正则匹配;

## 常见错误
错误1：
```
"proxy_pass" cannot have URI part in location given by regular expression, or inside named location, or inside "if" statement, or inside "limit_except"
```
如果location包含了正则表达式,则 "proxy_pass"不能包含URI part，即：`proxy_pass http://127.0.0.1:8082;` 最后不能有 ‘/’

```


# 精确匹配 / ，主机名后面不能带任何字符串
location = / {
	A
}

# 因为所有的地址都以 / 开头，所以这条规则将匹配到所有请求
# 但是正则和最长字符串会优先匹配
location / { 
	B
}

# 匹配任何以 /documents/ 开头的地址，匹配符合以后，还要继续往下搜索
# 只有后面的正则表达式没有匹配到时，这一条才会采用这一条
location /documents/ {
	C
}

# 匹配任何以 /documents/ 开头的地址，匹配符合以后，还要继续往下搜索
# 只有后面的正则表达式没有匹配到时，这一条才会采用这一条
location ~ /documents/Abc {
	CC
}

# 匹配任何以 /images/ 开头的地址，匹配符合以后，停止往下搜索正则，采用这一条。
location ^~ /images/ {
	D
}

# 匹配所有以 gif,jpg或jpeg 结尾的请求
# 然而，所有请求 /images/ 下的图片会被   D 处理，因为 ^~ 到达不了这一条正则
location ~* \.(gif|jpg|jpeg)$ {
	E
}

# 字符匹配到 /images/，继续往下，会发现 ^~ 存在
location /images/ {
	F
}

# 最长字符匹配到 /images/abc，继续往下，会发现 ^~ 存在
# F与G的放置顺序是没有关系的
location /images/abc {
	G
}

# 只有去掉   D 才有效：先最长匹配 config G 开头的地址，继续往下搜索，匹配到这一条正则，采用
location ~ /images/abc/ {
	H
}
```

location ~* /js/.*/\.js
已=开头表示精确匹配
如 A 中只匹配根目录结尾的请求，后面不能带任何字符串。
^~ 开头表示uri以某个常规字符串开头，不是正则匹配
~ 开头表示区分大小写的正则匹配;
~* 开头表示不区分大小写的正则匹配
/ 通用匹配, 如果没有其它匹配,任何请求都会匹配到
顺序不等于优先级：


# 代理

请求：`http://localhost/ws2Thank`  `'www.abc.com'` 收到的地址为 `http://www.abc.com/xxxThank`
```
location ^~ /ws2 {
	add_header Access-Control-Allow-Origin *;
	add_header Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept";
	add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
	
	include module/ex/location_http.conf;
	proxy_pass http://www.abc.com/xxx; 
	proxy_set_header Host fetch.$host;
}
```

## 绝对路径
```
location /proxy {
    proxy_pass http://192.168.137.181:8080/;
}
```
访问 `http://127.0.0.1/proxy/test/test.txt`时，nginx匹配到/proxy路径，
把请求转发给192.168.137.181:8080服务，实际请求路径为`http://10.0.0.1:8080/test/test.txt`，
nginx会去掉匹配的“/proxy”。

## 相对路径
```
location /proxy {
    proxy_pass http://10.0.0.1:8080;
}
```
当访问 http://127.0.0.1/proxy/test/test.txt时，nginx匹配到/proxy路径，
把请求转发给192.168.137.181:8080服务，实际请求代理服务器的路径为
`http://192.168.137.181:8080/proxy/test/test.txt`， 此时nginx会把匹配的“/proxy”也代理给代理服务器。
 
## 增加绝对路径
```
location /proxy {
    proxy_pass http://10.0.0.1:8080/static01/;
}
```
当访问 http://127.0.0.1/proxy/test/test.txt时，nginx匹配到/proxy路径，把请求转发给192.168.137.181:8080服务，实际请求代理服务器的路径为
http://10.0.0.1:8080/static01/test/test.txt。

## 去掉前缀
前缀只是为了让nginx用来区分转发到哪个服务器，不是实际URL的一部分。

例如我们需要代理访问http://10.0.0.1:8080/test/test.txt，如果不去掉前缀，  
nginx代理访问的就是http://192.168.137.181:8080/proxy/test/test.txt

### 方案1
一个种方案是上面提到的proxy_pass后面加根路径“/”。

### 方案2
另一种方案是使用正则重写url 
```
location /resource {
    rewrite  ^/resource/?(.*)$ /$1 break;
	#rewrite "^/resource/(.)$" /$1 break
    proxy_pass http://192.168.137.189:8082/; # 转发地址
}
```
- `^/resource/(.)$`  匹配路径的正则表达式，用了分组语法就是*(.)*，把/resource/以后的所有部分当做1组
- `/$1`		重写的目标路径，这里用$1引用前面正则表达式匹配到的分组（组编号从1开始，也就是api），即/resource/后面的所有。这样新的路径就是除去/resource/以外的所有，就达到了去除/resource前缀的目的；
- `break`		指令，重写路径结束后。
 