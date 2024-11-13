---
layout: post
title: msys64
subtitle:
date:       2022-04-01 10:47:23
categories: [C]
tags: [C,msys64]
---


(TOC)[交叉编译]

# 1. 编译步骤
  - `./configure`    	shell脚本，检测安装平台的目标特征  检测你是不是有 CC或GCC 等
		`–prefix=/usr`       软件安装在 /usr 下面,执行文件就会安装在 /usr/bin (默认/usr/local/bin),资源文件 /usr/share
		
  - `make` 				编译，从Makefile中读取指令，然后编译
  -  `make install`		安装，它也从Makefile中读取指令，安装到指定的位置。
  -  `make clean`		删除一些临时文件 清除编译产生的可执行文件及目标文件(object file，*.o)]
  -	 `make distclean`   除了清除可执行文件和目标文件外，把configure所产生的Makefile也清除掉。
  a.
  
# 2. mingw64
# 3. msys
# 4. NASM


1. perl Configure VC-WIN32 no-asm --prefix=c:\Openssl\out
    no-asm 不用汇编相关的信息 ，没有该参数  要额外安装NASM
2. ms\do_ms.bat         
    生成Makefile文件
3.  nmake -f ms\ntdll.mak          --编译动态库
     nmake -f ms\nt.mak             --静态库 
4.  nmake -f ms\ntdll.mak test   -- 测试动态库
5.  nmake -f ms\ntdll.mak install  -- 生成所需文件c:\Openssl\out