---
layout: post
title:  typescript 问题总结
subtitle: 摘录
description: 常见的思维方式

header-img: 
date:       2024-06-12 14:51:01
---

# 1. typings 文件夹
特殊文件夹，用于存放第三方库或模块的类型定义文件，为那些没有使用 TypeScript 编写的 JavaScript 库提供类型定义
ypeScript 2.0 常手动编写，使用定义文件（.d.ts）来为第三方库添加类型定义，而在 TypeScript 2.0 及以后的版本中，不再需要手动编写定义文件，而是通过 npm 安装所需库的 @types 包来获取类型定义
