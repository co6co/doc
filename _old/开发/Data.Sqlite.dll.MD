---
layout: post
title: Data.Sqlite.dll
subtitle:
date:       2021-05-08 09:26:41
categories: [开发]
tags: [开发,Data.Sqlite.dll]
---


[TOC](System.Data.SQLite.dll不能编译成AnyCPU问题的解决方案，以及它跨x86和x64的使用方法。)
# 打包成ANYCPU（间接）
`Data.SQLite.dll`可以认为是对用C编写的sqlite3.c的.NET平台的封装，
由于原`sqlite3.dll`是区分x86和x64发布的，`Data.SQLite.dll`一般也会区分`x86`和`x64`封装，结果可能会在实际使用时产生麻烦。

`Data.SQLite.dll` 
1. C#项目，会被生成Data.SQLite.dll和Data.SQLite.Linq.dll
2. C/C++项目，会被生成SQLite.Interop.dll

Data.Sqlite.dll的源代码中使用了两种C/C++和C#的交互方式，都可以达到在.NET平台利用C/C++代码的目的。
1. 以C#代码为主体，导入C/C++ dll的方式，这样会生成多个dll。
2. 以C/C++代码为主体，导入C# module的方式，这样只会生成一个dll。

**重点**
解决方案中`存在C/C++`项目，这是不能够`生成AnyCPU`的，所以引用该dll的程序，
如果必须要求生成在`AnyCPU中的话`，该dll的使用将会出现问题,
使用的解决方案：
1. 把C#项目生成的Data.SQLite.dll、x64目录下的x64版本的SQLite.Interop.dll、x86目录下的x86版本的SQLite.Interop.dll组合在一起使用。
2. 使用时，只需要引用Data.SQLite.dll，它的内部会根据当前平台的不同而调用不同的SQLite.Interop.dll，从而达到对AnyCPU都兼容的目的。

在官网中，在每个.NET版本分组中都有2个文件包，一个带有`bundle`字样，另一个没有
1.带有`bundle`字样的表示动态库是按混合模式编译的，在使用的时候只需要System.Data.SQLite.dll
2.不带`bundle`的则是将非托管部分和托管部分分别编译，System.Data.SQLite.dll不能独立使用，还需要有SQLite.Interop.dll才能使用。

如果要使用`Any CPU`的`System.Data.SQLite.dll`，就必须使用`不带bundle`字样，即`非混合编译`的二进制包,
`SQLite.Interop.dll`是可以放与`System.Data.SQLite.dll相同的目录`下，
也可以放在`x86或x64子目录`下，由System.Data.SQLite.dll根据系统类型调用。

# vs 中增加 SQLite 数据源
- 选择工具——扩展和更新——联机，搜索[`SQLite/SQL Server Compact ToolBox`](https://marketplace.visualstudio.com/items?itemName=ErikEJ.SQLServerCompactSQLiteToolbox)