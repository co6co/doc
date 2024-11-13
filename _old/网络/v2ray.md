---
layout: post
title: v2ray
subtitle:
date:       2021-11-10 14:03:31
categories: [网络]
tags: [网络,v2ray]
---


# 1. v2ray
不只是一个用于翻墙的工具，而更像是一款 代理服务器的组合套件

各种代理协议看成是一个个`协议模块`，
协议模块分为`出口协议`与`入口协议`
请求通过入口协议被服务器所接受,再通过中间的routes模块根据用户自定义的规则将数据从出口协议转发出去
出口入口协议基本涵盖了目前主流的代理协议,诸如HTTP代理，Socks代理，数据直连，Shadowsocks以及自身的vmess协议

## 2.1. 代理协议转换
socks协议并不对所有的软件都能友好支持的，有时候http代理协议被更多的软件所支持
privoxy这类经典的http代理软件，但实际上v2ray通过配置文件也能提供和privoxy类似的功能， 
即`socks协议转http协议`。

```
{
    "inbounds": [
        {
            "port": 8080,
            "listen": "127.0.0.1",
            "protocol": "http"
        }
    ],
    "outbounds":[
        {
            "protocol":"socks",
            "settings":{
                "servers":[
                    {"address":"127.0.0.1", "port":9150}
                ]
            }
        }
    ]

}

```

将本地位于9150的socks代理协议在本地8080端口处转换为HTTP代理协议

## 2.2 远程端口的本地映射
将远程的本地端口映射至本地，并且期间的通讯如果能有基本的加密功能就更完美了。
，请求内容尽可能不要暴露于ISP服务商
·`远程服务器`上有一些只能通过127.0.0.1地址访问的服务，希望能在`本地进行访问`,
结合v2ray的`dokodemo-door`协议将远程端口映射至本地。

 假设远程的服务器为S，需要映射的地址为127.0.0.1:8080。本地设备为C，被映射的端口为8081。
 
 服务器S的配置文件
 ```
 {
    "inbounds":[
        {
            "port":37192,
            "listen":"127.0.0.1",
            "protocol":"vmess",
            "settings":{
                "clients":[
                    {"id":"27848739-7e62-4138-9fd3-098a63964b6b", "alterId":4}
                ]
            }
        }
    ],
    "outbounds":[
        {
            "protocol":"freedom",
            "settings":{}
        }
    ]
}
 ```
 
 客户端C的配置文件

```
{
    "inbounds":[
        {
            "port" : 8081,
            "listen" : "127.0.0.1",
            "protocol": "dokodemo-door",
            "settings": {
                "address":"127.0.0.1",
                "port":8080,
                "network":"tcp,udp",
                "followRedirect":false
            }
        }
    ],
    "outbounds":[
        {
            "protocol": "vmess",
            "settings": {
                "vnext": [
                    {
                        "address": "s_ip_address",
                        "port": 37192,
                        "users": [
                            {
                            "id": "27848739-7e62-4138-9fd3-098a63964b6b",
                            "alterId": 4,
                            "security": "auto"
                            }
                        ]
                    }
                ]
            }
        }
    ]
}
```

dokodemo-door的settings中，所定义的address为在服务器S上所访问的地址。
因此通过该配置能实现远程服务器S 至本地客户端的端口映射。
通过该配置，也可以实现将只能通过S访问的地址服务，映射至本地的功能。

又因为S与C之间的通讯由v2ray的`vmess协议`保护，所以通讯本身也具有良好的安全性。

