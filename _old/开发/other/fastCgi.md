---
layout: post
title: fastCgi
subtitle:
date:       2021-10-15 09:35:07
categories: [other]
tags: [other,fastCgi]
---


# 概述
通信协议，和HTTP协议一样，都是进行数据交换的一个通道；
服务器中间件和某个语言后端进行数据交换的协议，Fastcgi协议由`多个record`组成。
record也有`header和body`
record的头固定8个字节，body是由头中的contentLength指定
```
typedef struct {
  /* Header */
  unsigned char version; // 版本
  unsigned char type; // 本次record的类型
  unsigned char requestIdB1; // 本次record对应的请求id  占两个字节
  unsigned char requestIdB0;
  unsigned char contentLengthB1; // body体的大小   		占两个字节
  unsigned char contentLengthB0;
  unsigned char paddingLength; // 额外块大小
  unsigned char reserved; 

  /* Body */
  unsigned char contentData[contentLength];
  unsigned char paddingData[paddingLength];
} FCGI_Record;

```

type指该record的作用
因为fastcgi一个record的大小是有限的，作用也是单一的，所以我们需要在一个TCP流里传输多个record。通过type来标志每个record的作用，用requestId作为同一次请求的id。
也就是说，每次请求，会有多个record，他们的requestId是相同的。


[fastcgi](https://www.leavesongs.com/PENETRATION/fastcgi-and-php-fpm.html)