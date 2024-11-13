---
layout: post
title: gvrp
subtitle:
date:       2022-02-09 14:28:56
categories: [交换机]
tags: [交换机,gvrp]
---


1、VLAN属性的单向注册

![VLAN属性的单向注册](/static/dev/交换机/imgs/VLAN属性的单向注册.png)
     


图1 VLAN属性的单向注册

在SwitchA上创建静态VLAN2，通过VLAN属性的单向注册，将SwitchB和SwitchC的相应端口自动加入VLAN2。

在SwitchA上创建静态VLAN2后，Port1启动Join定时器和Hold定时器，等待Hold定时器超时后，SwitchA向SwitchB发送第一个JoinEmpty消息，Join定时器超时后再次启动Hold定时器，再等待Hold定时器超时后，发送第二个JoinEmpty消息。

SwitchB上接收到第一个JoinEmpty后创建动态VLAN2，并把接收到JoinEmpty消息的Port2加入到动态VLAN2中，同时告知Port3启动Join定时器和Hold定时器，等待Hold定时器超时后向SwitchC发送第一个JoinEmpty消息，Join定时器超时后再次启动Hold定时器，Hold定时器超时之后，发送第二个JoinEmpty消息。SwitchB上收到第二个JoinEmpty后，因为Port2已经加入动态VLAN2，所以不作处理。

SwitchC上接收到第一个JoinEmpty后创建动态VLAN2，并把接收到JoinEmpty消息的Port4加入到动态VLAN2中。SwitchC上收到第二个JoinEmpty后，因为Port4已经加入动态VLAN2，所以不作处理。

此后，每当LeaveAll定时器超时或收到LeaveAll消息，设备会重新启动LeaveAll定时器、Join定时器、Hold定时器和Leave定时器。SwitchA的Port1在Hold定时器超时之后发送第一个JoinEmpty消息，Join定时器超时后再次启动Hold定时器，再等待Hold定时器超时后，发送第二个JoinEmpty消息，SwitchB向SwitchC发送JoinEmpty消息的过程也是如此。

 


2、VLAN属性的双向注册

![VLAN属性的双向注册](/static/dev/交换机/imgs/VLAN属性的双向注册.png) 


图2 VLAN属性的双向注册  

通过上述VLAN属性的单向注册过程，端口Port1、Port2、Port4已经加入VLAN2，但是Port3还没有加入VLAN2（只有收到JoinEmpty消息或JoinIn消息的端口才能加入动态VLAN）。为使VLAN2流量可以双向互通，需要进行SwitchC到SwitchA方向的VLAN属性的注册过程。

VLAN属性的单向注册完成后，在SwitchC上创建静态VLAN2（将动态VLAN转换成静态VLAN），Port4启动Join定时器和Hold定时器，等待Hold定时器超时后，SwitchC向SwitchB发送第一个JoinIn消息（因为Port4已经注册了VLAN2，所以发送JoinIn消息），Join定时器超时后再次启动Hold定时器，Hold定时器超时之后，发送第二个JoinIn消息。

SwitchB上接收到第一个JoinIn后，把接收到JoinIn消息的Port3加入到动态VLAN2中，同时告知Port2启动Join定时器和Hold定时器，等待Hold定时器超时后，向SwitchA发送第一个JoinIn消息，Join定时器超时后再次启动Hold定时器，Hold定时器超时之后，发送第二个JoinIn消息；SwitchB上收到第二个JoinIn后，因为Port3已经加入动态VLAN2，所以不作处理。

SwitchA上接收到JoinIn之后，停止向SwitchB发送JoinEmpty消息。此后，当LeaveAll定时器超时或收到LeaveAll消息，设备重新启动LeaveAll定时器、Join定时器、Hold定时器和Leave定时器。SwitchA的Port1在Hold定时器超时之后就开始发送JoinIn消息。

SwitchB向SwitchC发送JoinIn消息。

SwitchC收到JoinIn消息后，由于本身已经创建了静态VLAN2，所以不会再创建动态VLAN2。

 


3、VLAN属性的单向注销
 
![VLAN属性的单向注销](/static/dev/交换机/imgs/VLAN属性的单向注销.png) 

图3 VLAN属性的单向注销

当设备上不再需要VLAN2时，可以通过VLAN属性的注销过程将VLAN2从设备上删除。

在SwitchA上删除静态VLAN2，Port1启动Hold定时器，等待Hold定时器超时后，SwitchA向SwitchB发送LeaveEmpty消息。LeaveEmpty消息只需发送一次。

SwitchB上接收到LeaveEmpty，Port2启动Leave定时器，等待Leave定时器超时之后Port2注销VLAN2，将Port2从动态VLAN2中删除（由于此时VLAN2中还存在端口Port3，所以不会删除VLAN2），同时告知Port3 启动Hold定时器和Leave定时器，等待Hold定时器超时后，向SwitchC发送LeaveIn消息。由于SwitchC的静态VLAN2还没有删除，Port3在Leave定时器超时之前仍然能够收到Port4发送的JoinIn消息，所以SwitchA和SwitchB上仍然能够学习到动态的VLAN2。

SwitchC上接收到LeaveIn后，由于SwitchC上存在静态VLAN2，所以Port4不会从VLAN2中删除。

 


4、VLAN属性的双向注销

 
![VLAN属性的双向注销](/static/dev/交换机/imgs/VLAN属性的双向注销.png) 

图4 VLAN属性的双向注销

为了彻底删除所有设备上的VLAN2，需要进行VLAN属性的双向注销。

在SwitchC上删除静态VLAN2，Port4启动Hold定时器，等待Hold定时器超时后，SwitchC向SwitchB发送LeaveEmpty消息。

SwitchB接收到LeaveEmpty消息后，Port3启动Leave定时器，等待Leave定时器超时之后Port3注销VLAN2，将Port3从动态VLAN2中删除并删除动态VLAN2，同时告知Port2启动Hold定时器，等待Hold定时器超时后，向SwitchA发送LeaveEmpty消息。

SwitchA接收到LeaveEmpty消息后，Port1启动Leave定时器，等待Leave定时器超时之后Port1注销VLAN2，将Port1从动态VLAN2中删除并删除动态VLAN2。

-----------

为什么默认配置下通过GVRP创建和删除VLAN时CPU占用率高


交换机支持通过两端设备配置VLAN，网络内使能GVRP，GVRP协议通告动态VLAN，通过两个方向的VLAN通告，全部中间设备动态创建和删除VLAN。动态维护VLAN，可以避免大量的手工配置量。

满规格4K动态VLAN频繁创建和删除，会触发大量报文通信，接受报文和下发动态VLAN会占用大量的CPU。

因此，在实际组网中，GVRP的定时器需要按照推荐值进行调整。

建议用户将GVRP定时器配置为以下的推荐值：

GARP Hold定时器：100厘秒（1秒钟）

GARP Join定时器：600厘秒（6秒钟）

GARP Leave定时器：3000厘秒（30秒钟）

GARP LeaveAll定时器：12000厘秒（2分钟）当动态VLAN超过100个时，需将定时器配置为推荐值。当动态VLAN数增加时，定时器的时间也需要相应的增加。