---
layout: post
title: http
subtitle:
date:       2021-12-02 09:21:17
categories: [网络]
tags: [网络,http]
---


[DOC](HttpTTP)

# 0. 概述
HTTP协议为`半双工协议`。半双工协议指数据可以在客户端和服务端两个方向上传输，但是不能同时传输。它意味着在同一时刻，只有一个方向上的数据传送；

HTTP消息冗长而繁琐。HTTP消息包含消息头、消息体、换行符等

# 1. Http 请求消息
## 1.1. 组成
1. 请求行
	以 `Method` 开头，以空格分开，后面跟着请求的URL 和协议版本，
	`Method Request_URL Http_version CRLF` 
	`Method`: GET/POST/HEAD/PUT/DELETE/TRACE/CONNECT(保留使用)/OPTIONS(查询服务器性能或与资源相关的选项和需求)
	`CRLF`: 回车和换行 ，不允许出现单独的 `CR`或`LF`字符。 
2. 请求头
求消息头列表
|Key|作用|
|--|--|
|Accept|用于指定客户端接受那种类型的信息|
|Accept-Charset|用于指定科幻的接受的字符集|
|Accept-Encoding|类似于Accept，但它用于指定可接受的内容编码|
|Accept-Language|用于指定一种自然语言|
|Authorization|用于证明科幻端有权查看某个资源|
|Host|发送请求时，该报头饰必须的，用于指定被请求资源的Internet 主机和端口号，它通常是从HTTPURL中提出出来的|
|User-Agent|允许客户端将他的操作系统、浏览器和他的属性告诉服务器|
|Content-Length|消息体的长度|
|Content-Type|后面的文档属于什么MIME类型|
|Connection|连接类型|

3. 请求正文

# 2. Http 响应消息
状态行、消息报头、响应正文。
```
1xx			请求以接收，继续处理
2xx			已被成功接收，理解
	200		OK 请求成功
3xx			重定向，请求必须进行更进一步的操作
4xx			客户端错误，语法错误或请求无法实现
	400		BadRequest，客户端请求有语法错误，不能被服务器所理解
	401		Unauthorized 请求未经授权
	404		NotFound 资源不存在
5xx			服务器错误，服务器未能处理请求
	500		Internal Server Error 服务器发生不可预期的错误
	503		Server Unavailable	服务器当前不能处理客户端请求，一段时间后可能恢复
```
消息头：
```
Location 		用于重定向接受者到一个新的位置
Server			用来处理请求的软件信息，与User-Agent请求报文头域相对应
WWW-Autherticate	必须被包含在401 响应中

```


# webSocket
HTML5开始提供的一种浏览器与服务器间进行全双工通信的网络技术,
浏览器和服务器只需要做一个握手的动作，然后，浏览器和服务器之间就形成了一条快速通道，两者就可以直接互相传送数据了。

设计出来的目的就是要`取代`轮询和Comet技术，使客户端浏览器具备像C/S架构下桌面系统一样的实时通信能力
 
WebSocket的特点:
- 单一的TCP连接，采用全双工模式通信；
- 对代理、防火墙和路由器透明；
- 无头部信息、Cookie和身份验证；
- 无安全开销；
- 通过”ping/pong”帧保持链路激活；
- 服务器可以主动传递消息给客户端，不再需要客户端轮询。

webSocket 连接：
1. 为了建立一个WebSocket连接，客户端浏览器首先要向服务器发起一个HTTP请求，这个请求和通常的 HTTP请求不同，包含了一些附加头信息，其中附加头信息”Upgrade：WebSocket”表明这是一个申请协议升级的HTTP请求。
```
GET /chat HTTP/1.1
Host webSocket.co6co.top
Upgrade: webSocket
Connection: Upgrade
Sec-Websocket-Key: fqtRdfF8LoSefV90LwuffQ==	
Origin: http://co6co.top
Sec-WebSocket-Protocol: chat,superchat
Sec-WebSocket-Verion: 13


HTTP/1.1 101 Switching Protocols
Upgrade: webSocket
Connection: Upgrade
Sec-WebSocket-Accept: L91ZlAJEGfwdm+OvJZxsZGY4J+k=
Sec-WebSocket-Protocol: chat
```

请求中的`Sec-Websocket-Key` 是随机的 ，服务器会用着写数据构造出一个SHA-1的摘要，把`Sec-Websocket-Key`加上一个魔幻字符串`258EAFA5-E914-47DA-95CA-C5AB0DC85B11`，使用Sha1 加密，
然会使用Base-64 将结果作为`Sec-WebSocket-Accept` 的值返回给客户端。

2. 握手完成后
服务端和客户端就可以通过”messages”的方式进行通信了，一个消息由一个或者多个帧组成

帧都有自己对应的类型，属于同一个消息的多个帧具有相同类型的数据。
数据类型可以是文本数据（UTF-8[RFC3629]文字）、二进制数据和控制帧（协议级信令，如信号）。

3. WebSocket连接关闭
客户端和服务端需要通过一个安全的方法关闭底层TCP连接以及TLS会话。如果合适，丢弃任何可能已经接收的字节，必要时（比如受到攻击）可以通过任何可用的手段关闭连接。

底层的TCP连接，在正常情况下，应该首先由服务器关闭。在异常情况下（例如在一个合理的时间周期后没有接收到服务器的TCP Close），客户端可以发起TCP Close。因此，当服务器被指示关闭WebSocket连接时，它应该立即发起一个TCP Close操作；客户端应该等待服务器的TCP Close。

WebSocket的握手关闭消息带有一个状态码和一个可选的关闭原因，它必须按照协议要求发送一个Close控制帧，当对端接收到关闭控制帧指令时，需要主动关闭WebSocket连接。


