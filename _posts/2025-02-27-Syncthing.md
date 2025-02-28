---
layout: post
title:  Syncthing

header-img: 
date:   2025-02-27 16:21:01
modify: 2025-02-27 16:35:00
categories: [网络]
tags: [文件共享,Syncthing]
---

# 1. Syncthing 
连接自定义中继：
```
转到 Settings > Advanced。
找到 Custom Relay Servers 字段，输入自定义中继服务器地址:tcp://<中继服务器IP>:22000
```
连接自定义介绍服务器：
```
找到 Introducer 字段，输入自定义介绍服务器地址找到 Introducer 字段，输入自定义介绍服务器地址，例如 tcp://<介绍服务器IP>:21027
```

# 2. 介绍服务器
`syncthing --introducer=true --no-browser=true --no-default-folder=true`
默认情况下，Syncthing 使用端口 21027 作为介绍服务器端口。
```
<introducerPort>21027</introducerPort>
```
# 3. 中继服务器
允许设备通过该服务器转发数据包，从而实现间接通信。中继的主要作用是解决以下问题：
- NAT 穿透失败: 如果两台设备都位于不同的 NAT 后面，并且无法通过 UPnP 或其他方法直接连接。
- 防火墙限制: 如果某台设备被防火墙阻止，无法直接接收外部连接。
- 跨网络通信: 如果两台设备位于不同的局域网中，且没有公网 IP 地址。

在理想情况下，Syncthing 设备会尝试通过 P2P 方式直接通信。这通常通过设备之间的 IP 地址和端口进行。
如果设备在同一局域网内，它们可以直接发现并连接到彼此。当直接连接失败时，Syncthing 会尝试通过中继服务器建立连接。
中继服务器充当一个“桥梁”，将数据从一台设备转发到另一台设备。

- 公共中继
Syncthing 默认使用一组公共中继服务器，由社区维护。
这些服务器是免费的，但可能会受到带宽限制或偶尔的连接问题。
配置简单，只需启用中继功能即可。
- 私有中继
用户可以搭建自己的中继服务器，完全控制数据流向。
私有中继更安全，适合企业或对隐私要求较高的用户。
搭建私有中继需要一定的技术知识，并且需要一台始终在线的服务器。

## 3.2 搭建中继服务器
[下载](https://syncthing.net/?spm=5176.28103460.0.0.55715d27oWJ9Pw)
```
syncthing --relay=true --no-browser=true --no-default-folder=true
//--relay=true: 启用中继服务器模式。
//--no-browser=true: 禁止自动打开浏览器。
//--no-default-folder=true: 禁止创建默认同步文件夹。
```
默认情况下，Syncthing 使用端口 `22000` 作为中继端口
```
配置文件路径通常是 ~/.config/syncthing/config.xml。
windows 目录`C:\Users\Administrator\AppData\Local\Syncthing`
找到 <options> 部分，并设置 relayPort 属性

```
# 4. 其他
## 4.1 QUIC 协议
`quic://xx.xx.xx.xx:2200` 是一种 URI（统一资源标识符）

QUIC（Quick UDP Internet Connections）是由 Google 开发的一种传输层协议，后来被 IETF 标准化为通用协议。
它旨在替代传统的 TCP 协议，特别是在需要低延迟和高效率的应用场景中。QUIC 基于 UDP 协议运行，并结合了许多现代网络通信的最佳实践。
其特点是：
- 基于 UDP: 使用 UDP 作为底层传输协议，避免了 TCP 的三次握手延迟。
- 多路复用: 在单个连接中支持多个数据流，解决了 TCP 中的“队头阻塞”问题。
- 内置加密: 类似于 TLS，但更高效，减少了握手延迟。
- 连接迁移: 支持在不同网络之间无缝切换（例如从 Wi-Fi 切换到蜂窝网络）。
- 更低的延迟: 首次连接时只需要一次往返（1-RTT），甚至在某些情况下可以实现零往返（0-RTT）。

