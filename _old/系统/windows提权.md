---
layout: post
title: windows提权
subtitle:
date:       2023-04-07 15:50:30
categories: [系统]
tags: [系统,windows提权]
---


# 1. 交互式服务
获得 Trustedinstaller 的方式是，通过交互式服务检测，但是在最新的 Windows 11（Windows 10）中，这种方法已经失效了。

# 2. windows 10/11 
## a. 前期准备工作 
``` 
1. Save-Module -Name NtObjectManager -Path c:\token 
2. Install-Module -Name NtObjectManager # 安装模块库
3. Set-ExecutionPolicy Unrestricted # 执行策略更改
4. Import-Module NtObjectManager #导入 NtObjectManager 模块
```
## b. 依次输入 
```
sc.exe start TrustedInstaller
Set-NtTokenPrivilege SeDebugPrivilege
$p = Get-NtProcess -Name TrustedInstaller.exe
$proc = New-Win32Process cmd.exe -CreationFlags NewConsole -ParentProcess $p
```
## c. 接下来系统会打开一个命令提示符，该命令提示符就具有 Trustedinstaller 权限
```
whoami /groups /fo list
```
注意：不要使用 CMD 运行 explorer，因为 explorer 无法在当前用户下正常使用
在这之后如果，想要重新获得 Trustedinstaller 权限重新执行b步骤命令即可