---
layout: post
title: widnows驱动技术笔记 
categories: [技术, 安全,驱动]
tags: [windows,DDk,]
date: 2026-2-9 10:19:01
---

# 1. 安装驱动开发包
DDK（Driver Devement Kit），安装是选择全部安装(除了基本的编译环境外，DDK还提供大量的源代码和使用工具，对于初学者僵尸非常有用的)，安装完后主要用到Build Environment。
## 1.1 类型
windows 驱动程序分为两类：
- 不支持即插即用功能的**NT式驱动程序**
- 支持即插即用功能的**WDM驱动程序**

## 1.2 TNDDK.h 文件
文件里包含了对DDK的所有到处函数的声明，是NT式驱动程序要到款式的头文件,另外该文件中定义了几个标签，分别在程序中知名函数和变量分配在分页内存中或非分页内存中；
而WDM式驱动程序要导入的头文件为WDM.h;

## 1.3. 入口函数
与普通的应用程序不同，windows驱动程序的入口函数不是main函数，而是一个叫做 DriverEntry的函数。
DriverEntry函数有内核中的I/O管理器负责调用，函数有两个参数：pDriverObject 和pRegistryPath,
其中，pDriverObject 是I/O 管理器传递进来的驱动对象，pRegistryPath是一个Unicode字符串，只想此驱动负责的注册表
## 1.4. 卸载驱动例程
卸载驱动例程用来设备被卸载的情况，由I/O管理器负责调用此回调函数。此例程遍历系统中所有的此类设备对象。第一个设备对象的地址存在于驱动对象的DeviceObject域中，每个设备对象的NextDevice域记录着下一个设备对象的地址，这样就形成一个链表。卸载驱动例程的主要目的就是遍历系统中所有的此类设备对象，然后删除设备对象以及符号链接。
## 1.5 默认派遣例程
对设备对象的创建、关闭和读写操作，都被指定到这个默认的派遣例程中。由于这是一个最简单的演示程序，故只是简单地将其成功返回。

## 1.6 示例代码
```
extern "C" NTSTATUS DriverEntry(
    IN PDRIVER_OBJECT pDriverObject,
    IN PUNICODE_STRING pRegistryPath)
{
    NTSTATUS status;
    KdPrint(("Enter DriverEntry\n"));
    //注册其他驱动函数入口
    pDriverObject->DriverUnload= HelloDDKUnload;
    pDriverObject->MajorFunction["IRP_MJ_CREATE"]=HelloDDKDispathRoutine;
    pDriverObject->MajorFunction["IRP_MJ_CLOSE"]=HelloDDKDispathRoutine;
    pDriverObject->MajorFunction["IRP_MJ_WRITE"]=HelloDDKDispathRoutine;
    pDriverObject->MajorFunction["IRP_MJ_READ"]=HelloDDKDispathRoutine;

    //创建驱动设备对象
    status=CreateDevice(pDriverObject);

    KdPrint("DriverEntry end\n");
    return status;
}    

/************************************************************************
* 函数名称:CreateDevice
* 功能描述:初始化设备对象
* 参数列表:
　　pDriverObject:从I/O管理器中传进来的驱动对象
* 返回值:返回初始化状态
*************************************************************************/
#pragma INITCODE
NTSTATUS CreateDevice (
　　　　IN PDRIVER_OBJECT　　pDriverObject)
{
　　NTSTATUS status;
　　PDEVICE_OBJECT pDevObj;
　　PDEVICE_EXTENSION pDevExt;
　　//创建设备名称
　　UNICODE_STRING devName;
　　RtlInitUnicodeString(&devName,L"\\Device\\MyDDKDevice");
　　//创建设备
　　status =IoCreateDevice( pDriverObject,
　　　　　　　　　　　　sizeof(DEVICE_EXTENSION),
　　　　　　　　　　　　&(UNICODE_STRING)devName,
　　　　　　　　　　　　FILE_DEVICE_UNKNOWN,
　　　　　　　　　　　　0, TRUE,
　　　　　　　　　　　　&pDevObj );
　　if (!NT_SUCCESS(status))
　　　　return status;
　　pDevObj->Flags |=DO_BUFFERED_IO;
　　pDevExt =(PDEVICE_EXTENSION)pDevObj->DeviceExtension;
　　pDevExt->pDevice =pDevObj;
　　pDevExt->ustrDeviceName =devName;
　　//创建符号链接
　　UNICODE_STRING symLinkName;
　　RtlInitUnicodeString(&symLinkName,L"\\??\\HelloDDK");
　　pDevExt->ustrSymLinkName =symLinkName;
　　status =IoCreateSymbolicLink( &symLinkName,&devName );
　　if (!NT_SUCCESS(status))
　　{
　　　　IoDeleteDevice( pDevObj );
　　　　return status;
　　}
　　return STATUS_SUCCESS;
}
/************************************************************************
　* 函数名称:HelloDDKUnload
　* 功能描述:负责驱动程序的卸载操作 [由I/O管理器负责调用此回调函数]
　* 参数列表:
　　　pDriverObject:驱动对象
　* 返回值:返回状态
*************************************************************************/
#pragma PAGEDCODE
VOID HelloDDKUnload (IN PDRIVER_OBJECT pDriverObject)
{
　　PDEVICE_OBJECT　　pNextObj;
　　KdPrint(("Enter DriverUnload\n"));
　　pNextObj =pDriverObject->DeviceObject;
　　while (pNextObj !=NULL)
　　{
　　　　PDEVICE_EXTENSION pDevExt =(PDEVICE_EXTENSION)
　　　　　　pNextObj->DeviceExtension;
　　　　//删除符号链接
　　　　UNICODE_STRING pLinkName =pDevExt->ustrSymLinkName;
　　　　IoDeleteSymbolicLink(&pLinkName);
　　　　pNextObj =pNextObj->NextDevice;
　　　　IoDeleteDevice( pDevExt->pDevice );
　　}
}
//默认派遣例程
/************************************************************************
　* 函数名称:HelloDDKDispatchRoutine
　* 功能描述:对读IRP进行处理
　* 参数列表:
　　　pDevObj:功能设备对象
　　　pIrp:从I/O请求包
　* 返回值:返回状态
　*************************************************************************/
#pragma PAGEDCODE
NTSTATUS HelloDDKDispatchRoutine(IN PDEVICE_OBJECT pDevObj,
　　　　　　　　　　　　　　　　 IN PIRP pIrp)
{
　　KdPrint(("Enter HelloDDKDispatchRoutine\n"));
　　NTSTATUS status =STATUS_SUCCESS;
　　// 完成IRP
　　pIrp->IoStatus.Status =status;
　　pIrp->IoStatus.Information =0;　　// bytes xfered
　　IoCompleteRequest( pIrp, IO_NO_INCREMENT );
　　KdPrint(("Leave HelloDDKDispatchRoutine\n"));
　　return status;
}
```
# 2. 编译和安装
可以使用：
- 传统的用DDK编译环境编译，
- 用Visual C++（以下简称VC）集成开发环境编译

## 2.1 用DDK环境编译
是DDK文档中所提倡的办法。此种方法需要编写一个编译脚本文件，在这个脚本中描述了DDK驱动程序的源文件、用到的lib文件和inlcude路径名、编译输出的目录和文件名等信息，编写此类脚本对于Windows程序员可能比较陌生，尤其是当源文件较多时，编写脚本文件可能显得更如麻烦。
在源程序的相同目录下创建两个文件makefile和Sources，这两个文件都是文本文件，内容如下
```
//Sources
TARGETNAME=HelloDDK  
TARGETTYPE=DRIVER
TARGETPATH=OBJ
INCLUDES=$(BASEDIR)\inc;\
$(BASEDIR)\inc\ddk;\
SOURCES=Driver.cpp\
```
说明：
第1行说明此驱动的名称。
第2行指明此驱动的类型为NT型驱动。
第3行设置编译输出目录。
第5~6行设置include目录。
第8行指定源文件。

编写完这两个脚本后，在Windows的开始菜单中选择“Windows XP Checked Build Environment”编译环境。这里选择的是Checked版本，而不是Free版本。两者的区别类似于Win32程序开发的Debug版本和Release版本
## 2.2 VC集成开发环境编译
a. 用VC建立一个新工程。在VC IDE环境中选择“File”|“New”，弹出“New”对话框。在该对话框中，选择“Project”选项卡。在“Project”选项卡中，选择Win32 Application（因为VC并没有提供驱动程序的工程，所以在Win32工程的基础上进行修改）。工程名为“DriverDev”，如图1-5所示。单击“OK”按钮，进入下一个对话框。在该对话框中，选择一个空的工程;
b. 将两个源文件Driver.h和Driver.cpp拷贝到工程目录中，并添加到工程中;
c. 修改工程属性。选择“Project”|“Setting”，或者直接按下Alt+F7键，弹出“Project Settings”对话框。在对话框中，选择“General”选项卡。将Intermediate files和Output files改为MyDriver_Check

# 3. Hello DDK 安装
NT式驱动程序类似于Windows服务程序，以服务的方式加载在系统中。为了简化步骤，这里利用一个叫做DriverMonitor的工具软件加载HelloDDK。DriverMonitor是Compuware公司开发的DriverStudio中的一个工具，推荐读者安装DriverStudio，因为它提供的一系列工具对调试驱动非常有用。


