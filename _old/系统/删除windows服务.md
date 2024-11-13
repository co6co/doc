---
layout: post
title: 删除windows服务
subtitle:
date:       2021-08-26 16:30:59
categories: [系统]
tags: [系统,删除windows服务]
---


1. 移除 Xbox
```
echo 移除 Xbox 相关应用...
Get-AppxPackage Microsoft.Xbox.TCUI | Remove-AppxPackage
Get-AppxPackage Microsoft.XboxGameOverlay | Remove-AppxPackage
Get-AppxPackage Microsoft.XboxGamingOverlay | Remove-AppxPackage
Get-AppxPackage Microsoft.XboxIdentityProvider | Remove-AppxPackage
Get-AppxPackage Microsoft.XboxSpeechToTextOverlay | Remove-AppxPackage

echo 移除  Xbox...
Get-AppxPackage Microsoft.XboxApp | Remove-AppxPackage
```

```
Get-AppxPackage *3dbuilder* | Remove-AppxPackage
Get-AppxPackage *officehub* | Remove-AppxPackage
Get-AppxPackage *skypeapp* | Remove-AppxPackage
Get-AppxPackage *getStarted* | Remove-AppxPackage
Get-AppxPackage *zunemusic* | Remove-AppxPackage
Get-AppxPackage *bingfinance* | Remove-AppxPackage
Get-AppxPackage *bingnews* | Remove-AppxPackage
Get-AppxPackage *OneNote* | Remove-AppxPackage
Get-AppxPackage *personas* | Remove-AppxPackage
Get-AppxPackage *bingsports* | Remove-AppxPackage
Get-AppxPackage -Name king.com.CandyCrushSaga | Remove-AppxPackage

Get-AppxPackage Microsoft.Microsoft3DViewer | Remove-AppxPackage

```