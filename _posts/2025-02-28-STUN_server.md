---
layout: post
title:  STUN server 

header-img: 
date:   2025-02-27 16:21:01
modify: 2025-02-27 16:35:00
categories: [技术]
tags: [STUN server,NAT ]
---

# 1. STUN server 
STUN（Session Traversal Utilities for NAT，NAT会话穿越应用程序）是一种网络协议，它允许位于NAT（或多重NAT）后的客户端找出自己的公网地址，
查出自己位于哪种类型的NAT之后以及NAT为某一个本地端口所绑定的Internet端端口。这些信息被用来在两个同时处于NAT路由器之后的主机之间创建UDP通信。该协议由RFC 5389定义.

## 1.2 STUN 三个特点
a. 获取经过NAT转换后的地址和接口，服务记录接收到的UDP包的发起地址和端口
b. 检测是否位于NAT后面
	Server在收到client发送的UDP包以后，Server将接收该包的地址和端口利用UDP再传回给CLient，client把Server发送过来的地址和端口信息与本机的ip地址和端口进行比较，如果不同，说明在NAT后面；如果相同就说明client位于NAT前面，client也是公网。
c. 检测NAT的类型
这个主要发送响应的时候使用不同IP地址和端口或者改变端口等等。这个检测是对NAT一般情况下有效，但是对防火墙就无能为力了，因为防火墙可能不会打开UDP端口。

## 1.3 NAT类型判断流程
STUN是RFC3489规定的一种NAT穿透方式，它采用辅助的方法探测NAT的IP和端口。STUN的探测过程需要有一个公网IP的STUN server，在NAT后面的UAC必须和此server配合，互相之间发送若干个UDP数据包。UDP包中包含有UAC需要了解的信息，比如NAT外网IP，PORT等等。UAC通过是否得到这个UDP包和包中的数据判断自己的NAT类型。
NAT的探测过程
假设有如下UAC（B），NAT（A），SERVER（C），UAC的IP为IPB，NAT的IP为IPA ，SERVER的IP为IPC1 、IPC2。
a. STEP1
B向C的IPC1的port1端口发送一个UDP包。C收到这个包后，会把它收到包的源IP和port写到UDP包中，然后把此包通过IPC1和port1发还给B。这个IP和port也就是NAT的外网IP和port，也就是说你在STEP1中就得到了NAT的外网IP。
如果向一个STUN服务器发送数据包后，没有收到STUN的任何回应包，那只有两种可能：1、STUN服务器不存在，或者弄错了port；2、NAT设备拒绝一切UDP包从外部向内部通过(不支持cone NAT)。
当B收到此UDP后，把此UDP中的IP和自己的IP做比较，如果是一样的，就说明自己是在公网，下步NAT将去探测防火墙类型。如果不一样，说明有NAT的存在，系统进行STEP2的操作。
b. STEP2
B向C的IPC1发送一个UDP包，请求C通过另外一个IPC2和PORT（不同与SETP1的IPC1）向B返回一个UDP数据包（server两个IP是为了检测cone NAT的类型）。
如果B收到了这个数据包，说明NAT来者不拒，不对数据包进行任何过滤，这也就是STUN标准中的full cone NAT。遗憾的是，full cone nat太少了，这也意味着能收到这个数据包的可能性不大。如果没收到，那么系统进行STEP3的操作。
c. STEP3
B向C的IPC2的port2发送一个数据包，C收到数据包后，把它收到包的源IP和port写到UDP包中，然后通过自己的IPC2和port2把此包发还给B。
和step1一样，B肯定能收到这个回应UDP包。此包中的port是我们最关心的数据。如果这个port和step1中的port一样，那么可以肯定这个NAT是个CONE NAT，否则是对称NAT。道理很简单：根据对称NAT的规则，当目的地址的IP和port有任何一个改变，那么NAT都会重新分配一个port使用，而在step3中，和step1对应，我们改变了IP和port。因此，如果是对称NAT,那这两个port肯定是不同的。
如果到此步的时候PORT是不同的，那么你的STUN已经死了。如果相同，那么只剩下了restrict cone 和port restrict cone，系统用step4探测是是哪一种。
d. STEP4
B向C的IPC2的一个端口PD发送一个数据请求包，要求C用IPC2和不同于PD的port返回一个数据包给B。
如果B收到了，那也就意味着只要IP相同，即使port不同，NAT也允许UDP包通过，显然这是restrict cone NAT。如果没收到，没别的好说，port restrict NAT。




# 2. NAT穿透
穿透NAT，一般使用UDP协议，TCP协议也可以穿透，只是好像没有UDP成功率高。

一般情况，使用STUN协议.
除了要通信的两个端点之外，还有一个**有公网IP**的一个服务器 STUN server。
一个端点穿过防火墙，发个消息给STUN server，STUN server收到这个包之后 就可以知道该端点通过防火墙映射后的公网地址。
同样道理，STUN sever可以得到另外一个端点的通过它的防火墙映射后的公网地址。
STUN server把得到的这两个地址发给两个端点。
端点得到对方端点的公网地址后，就可以给对方端点发消息。相互就可以通信。
通俗的说，一个端点发一个UDP消息出去之后，就把自己的墙打了一个洞；另外一个端点也把它的墙打了一个洞。然后双方都可以向对方的洞发数据，进行通信 。