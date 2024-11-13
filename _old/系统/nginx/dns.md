---
layout: post
title: dns
subtitle:
date:       2021-09-06 10:38:57
categories: [nginx]
tags: [nginx,dns]
---


# nginx 使用DNS 

nginx会在启动时候将配置中涉及到的域名请求DNS解析，
获取到解析结果（所有的DNS解析 多个解析到的IP，当一个IP 不同会自动切换到其他IP进行访问）后，就缓存下来一直使用，直到下次执行reload或restart时候


 直接配置代理的地址
```
server {
    ...
    proxy_pass http://api.example.com;
    ...
}
```
还是通过upstream配置代理地址：
```
upstream backend {
    server api.example.com;
} 
server {
    ...
    proxy_pass http://backend;
    ...
}
```
都会存在域名在启动时候`被缓存住`，在域名有变更时候不会重新解析的问题。
 
 
# 解决方案
0. 更改 DNS 解析都重载 Nginx
重载 Nginx 一定会刷新缓存，这是最保险也是最麻烦的一种方案

1. 使用 Nginx 的 resolver

一开始是不会去进行 DNS 解析的，只有请求的时候才会进行 DNS 解析，并且要设置 resolver 指定 DNS 服务器 IP。
这个时候，我们就可以`使用 resolver 语法来解决 DNS 缓存的问题`，
比如说，我在原来的 Nginx 配置里指定 DNS IP，并设置缓存 60 秒。

```
server {
    listen 80;
    server_name www.abc.com;

    resolver 127.0.0.1 valid=60s;
    resolver_timeout 3s;

    set $proxy_url "proxy.abc.com";
    location / {
        proxy_set_header Host proxy.abc.com;
        proxy_pass http://$proxy_url;
    }
}
```
 

2. 使用模块`nginx-upstream-dynamic-servers` 
模块在第一次启动的时候会进行一次解析，解析完后，在 DNS 服务器设定的 `TTL` 过期时间内不会再次更新，过期后会再次发起解析请求
```
http {
  resolver 8.8.8.8;

  upstream abc {
    server www.abc.com resolve;
  }
}
```

3. 使用模块 `ngx_upstream_jdomain`

	[domain_resolve 模块](https://www.nginx.com/resources/wiki/modules/domain_resolve/)

  模块是一个依赖 DNS 解析实现的 upstream 负载均衡，该模式下，
  允许使用域名来写 upstream 后端。
  该模块默认情况下，会`每秒做一次 DNS 解析`，使用方法如下
```
	http {
		resolver 8.8.8.8;
		resolver_timeout 10s;

		upstream backend {
			server 127.0.0.1:55555 backup;
			jdomain example.com;
			keepalive 8;
		}
		upstream backend2 {
			jdomain www.abc.com port=80 interval=5; # 每 5 秒解析一次
		}
		server {
			listen 55555;
			return 502 'Panic!';
		}
		server {
			listen 80;
			location / {
				proxy_pass http://backend2;
			}
		}
		server {
			listen 8080;
			location / {
				 proxy_pass http://backend;
			}
		}
	}
```
2. 社区版 
(ngx_http_proxy_module - proxy_pass)[http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass]
在proxy_pass的参数值中，如果包含了变量，不管是域名还是upstream名，
直接当作upstream来处理，直接转到upstream的模块中去解析，如果没有匹配到相应的server group，
再当做域名进行DNS解析，如果还是解析不了，则会直接报错退出。

所以，解决问题的关键就在于利用proxy_pass参数值包含变量的情况，让nginx进行动态解析。
