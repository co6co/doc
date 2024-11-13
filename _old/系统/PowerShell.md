---
layout: post
title: PowerShell
subtitle:
date:       2021-10-14 10:38:21
categories: [系统]
tags: [系统,PowerShell]
---


# PowerShell
# 2. 升级
//查看版本
```
>$PSVersionTable
Name                           Value
----                           -----
PSVersion                      4.0
WSManStackVersion              3.0
SerializationVersion           1.1.0.1
CLRVersion                     4.0.30319.42000
BuildVersion                   6.3.9600.18773
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0}
PSRemotingProtocolVersion      2.2

```
保你已经安装了.net 4.5以上
[ps5.1](https://www.microsoft.com/en-us/download/details.aspx?id=54616)


# 3. 
```
::error  无法从 URI“https://go.microsoft.com/fwlink/?LinkID=627338&clcid=0x409”下载到“” 
:: 执行下面命令
>[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```