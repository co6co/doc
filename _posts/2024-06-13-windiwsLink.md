---
layout: post
title:  Windows Link
subtitle: 创建符号链接
description: 创建符号链接

header-img: 
date:       2024-06-13 14:19:01
categories: [windows]
tags: [符号链接]
---
# 1. MKLINK 
```
C:\Users\Administrator>mklink
创建符号链接。

MKLINK [[/D] | [/H] | [/J]] Link Target

        /D      创建目录符号链接。默认为文件
                符号链接。
        /H      创建硬链接而非符号链接。
        /J      创建目录联接。
        Link    指定新的符号链接名称。
        Target  指定新链接引用的路径
                (相对或绝对)。
```

- /d：建立目录的符号链接 (symbolic link)
- /j：建立目录的软链接（联接）(junction)
- /h：建立文件的硬链接 (hard link)

```
mklink /j vue H:\Work\Projects\html\py\app\demo-npm\node_modules\.pnpm\vue@3.2.37\node_modules\vue
```
