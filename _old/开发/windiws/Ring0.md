---
layout: post
title: Ring0
subtitle:
date:       2023-01-11 15:39:42
categories: [windiws]
tags: [windiws,Ring0]
---


# 1. Ring 0
在CPU的所有指令中，有一些指令是非常危险的，如果用错了会导致系统崩溃。
比如：清除内存数据、设置时钟等。
如果应用程序能随意调用属于不同权限的这些指令，
那么系统会出现各种各样的无解问题。
所以，CPU将指令分为特权指令和非特权指令，
对于那些危险的指令，只允许操作系统及其相关模块使用，
普通的应用程序只能使用那些不会造成灾难的指令。
比如普通应用程序企图执行Ring 0指令，则Windows会显示“非法指令”错误信息。
而这次波及甚广的CPU漏洞，就是可以通过非法指令直接调用到Ring 0权限！
所以从安全角度看确实危险，唯一的好消息是目前尚未有人实现过这种攻击。


近三年Intel CPU中的ME管理引擎是基于`Ring -3`权限的——这个权限就是至高无上的，
它不依赖于任何系统之上，说白了就是CPU内部的一个完整系统！
可以说，如果这个漏洞被人掌握了技术攻击方式，
你的电脑从技术上将不属于你，因为ME管理引擎使用的权限太高了，
就是CPU内的一个原生操作系统！当然了，现在也有相应补丁，
而且只影响4代酷睿以后的产品，范围比这此的情况小不少。


1. DDK: Driver Development Kit  驱动程序开发包,例如我们写的3环系统下,用到的SDK,也可以成为是API.只不过现在叫做内核方法(内核函数)了.
2. WDK:Windows Driver Kit 
   WDK是DDK升级而来的.操作系统为了支持热插拔,所以对DDK升级了.热插拔就是U盘插入系统.不用安装驱动了.和U盘绑定在一起了.
   注：编写驱动程序,请下载对应系统的WDK,因为驱动程序不兼容.只会跟着系统走.
   
# 2. 内核驱动
不论是驱动程序还是应用程序都`只会有一个入口点`
驱动程序入口点（kerner model 内核模型）：
安装完WDK之后，会有帮助文档；

编写硬件驱动，寻找WDM即可
```
NTSTATUS 
  DriverEntry( 　　　　　　　　//驱动的入口点
    __in struct _DRIVER_OBJECT  *DriverObject,
    __in PUNICODE_STRING  RegistryPath 
    )
  {...} 
```

返回值: STATUS_SUCCESS

内核输出的API
```
ULONG
  DbgPrint(
    IN PCHAR  Format,
    . . . .  [arguments] 
    );
```
利用入口我们可以简单编写一个内核驱动了.

```
#include <Ntddk.h> //编写内核驱动需要包含NTddk头文件.

NTSTATUS DriverEntry(__in struct _DRIVER_OBJECT  *DriverObject,
                      __in PUNICODE_STRING  RegistryPath)
{
    int i = 0;
    DbgPrint("HelloWorld, %p\r\n",&i);
    
    return STATUS_SUCCESS;
}
```
在编译驱动程序时,我们需要一个sources  文件，格式为：
```
TARGETNAME= MyFirstDrive    　　　　　　 //指明编译的文件名 
TARGETTYPE=DRIVER        　　　　　　    //指明编译的类型
SOURCES= MyFirstDrive.c        　　　　  //指明编译的文件
```
进入WDK 命令行工具：
```
> build MyFirstDrive.c
```
即可生成 MyFirstDrive.sys 驱动文件

## 2.2 调试
使用加载驱动工具，加载`MyFirstDrive.sys`,就可以在调试器中看见我们的驱动代码

![调试工具](/static/开发/windiws/imgs/drive/调试工具.png)
 
地址是高2G的空间.所以我们就进入了0环空间了.

## 2.3 卸载功能
上面的驱动只能 加载/启动/停止，但不能卸载，
我们需要编写卸载函数；
```
#include <Ntddk.h> //编写内核驱动需要包含NTddk头文件.
//卸载回调函数
VOID Unload(__in struct _DRIVER_OBJECT  *DriverObject)
{
  DbgPrint("Unload MyDrive\n");
}
NTSTATUS DriverEntry(__in struct _DRIVER_OBJECT  *DriverObject,
                      __in PUNICODE_STRING  RegistryPath)
{
    int i = 0;
    DbgPrint("HelloWorld, %p\r\n",&i);
    
    //注册一下驱动卸载的函数
    DriverObject->DriverUnload = Unload;

    return STATUS_SUCCESS;
}
```

给个卸载的函数指针即可.注意启动入口点的参数是一个结构体.启动你想要支持卸载驱动.那么就写上卸载驱动的函数指针即可.

## 2.4 蓝屏
编写驱动代码,不像我们编写ring3下的应用程序,崩溃了就是崩溃了. 编写驱动时只要程序异常,那么就会蓝屏.
```
#include <Ntddk.h> //编写内核驱动需要包含NTddk头文件.

//卸载回调函数
VOID Unload(__in struct _DRIVER_OBJECT  *DriverObject)
{
  DbgPrint("Unload MyDrive\n");
}

NTSTATUS DriverEntry(__in struct _DRIVER_OBJECT  *DriverObject,
                      __in PUNICODE_STRING  RegistryPath)
{
    int i = 0;
    int *p = NULL;   //异常代码.会造成C05访问异常.
    DbgPrint("HelloWorld, %p\r\n",&i);
    
   
    *p = 1;　　　　　　　//代码会产生异常,系统会蓝屏.

    //注册一下驱动卸载的函数
    DriverObject->DriverUnload = Unload;
    return STATUS_SUCCESS;
}
```
