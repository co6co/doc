---
layout: post
title: windowsLOG
subtitle:
date:       2021-07-28 09:27:44
categories: [系统]
tags: [系统,windowsLOG]
---


系统日志：
%SystemRoot%\System32\Winevt\Logs\System.evtx
安全日志：
%SystemRoot%\System32\Winevt\Logs\Security.evtx
应用程序日志：
%SystemRoot%\System32\Winevt\Logs\Application.evtx 
日志在注册表的键：
HKEY_LOCAL_MACHINE\system\CurrentControlSet\Services\Eventlog

PowerShell -Command "& {Clear-Eventlog -Log Application,System,Security}" Get-WinEvent -ListLog Application,Setup,Security -Force | % {Wevtutil.exe cl $_.Logname}
eventcreate -l system -so administrator -t warning -d "this is a test" -id 500


IIS默认日志路径：
%SystemDrive%\inetpub\logs\LogFiles\W3SVC1\

清除WWW日志：
停止服务：net stop w3svc
删除日志目录下所有文件：del %SystemDrive%\inetpub\logs\LogFiles\W3SVC1\*.*
启用服务：net start w3svc

run event_manager  -c

远程桌面：
@echo offreg delete "HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Default" /va /freg delete "HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Servers" /freg add "HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Servers"cd %userprofile%\documents\attrib Default.rdp -s -hdel Default.rdp
