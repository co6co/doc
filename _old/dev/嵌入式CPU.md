---
layout: post
title: 嵌入式CPU
subtitle:
date:       2022-04-14 09:50:18
categories: [dev]
tags: [dev,嵌入式CPU]
---


# 1. 概念
## 1.1 ARM64
由Apple创建的，iPad称自己为ARM64，使用LLVM(增强版Gcc)
## 1.2 AARCH64
由GNU/GCC的创建，Edge使用AARCH64，Android使用GNU GCC工具链一样

## 1.3 ARMV8
是Armv7之后的一个重要架构更新。其中一个主要的变化是引入了64的架构，  
即AArch64。AArch64状态只有在Armv8架构中才有。  
而且在AArch64状态下执行的代码只能使用A64指令集。  
当然ARM为了维持整个生态参与者的利益，Armv8还是保持与现有32位体系结构兼容性的AArch32，即Armv8之前的Armv7配置文件定义的那套设计规范;

`risc`的典型代表ARM,在arm的发展过程中引入了部分复杂指令,ARM 是risc基础外加`cisc`技术的cpu，  
arm的主要专利技术在arm公司手中，像高通，三星，苹果这些公司需要拿到arm的授权。  

### 1.3.1 armel、armhf和arm64
armel:是arm eabi little endian的缩写。eabi是软浮点二进制接口，这里的e是embeded，是对于嵌入式设备而言。  
armhf:是arm hard float的缩写。  
arm64:64位的arm默认就是hf的，因此不需要hf的后缀。

armel和armhf的区别
它们的区别体现在浮点运算上，它们在进行浮点运算时都会使用fpu，但是armel传参数用普通寄存器，而armhf传参数用的是fpu的寄存器，因此armhf的浮点运算性能更高。  
gcc编译的时候，使用-mfloat-abi选项来指定浮点运算使用的是哪种，soft不使用fpu，armel使用fpu，使用普通寄存器，armhf使用fpu，使用fpu的寄存器 。  
编译时，kernel、rootfs和app的指定必须一致才行。
在一些特定场景中， armhf 代表的是 32 位，arm64 才是代表 64 位(比如说树莓派)。

## 1.4 X86和X86_64(AMD64)
早期时Intel先是自己搞了个`x86架构`，然后amd拿到了x86的授权也可以自己做x86了。接着intel向64位过渡的时候自己搞了个`ia64（x64架构）`但是因为和x86架构不兼容市场反应极差，
amd率先搞了x86的64位兼容（32和64的混合架构）也就是后来的`x86-64`，后来Intel也拿到了生产这货的授权，也搞了x86-64，
因为amd先搞出来的所以x86-64也叫`amd64`
x64架构目前只有intel 安腾而且已经放弃了产品线
intel和amd的x86架构cpu虽然`指令集上有很大差别`了,但是还是相互兼容的，所以软件可以直接用。

x86是cisc的代表，后来的发展中逐步引入了`risc`的`部分理念`，将内部指令的实现大量模块化;

## 1.5 MIPS
另一个risc的典型处理器就是`mips`,学院派的cpu,授权门槛极低，因此很多厂家都做mips或者mips衍生架构。  
mips架构cpu主要用在嵌入式领域;

其中国的龙芯loongisa架构其实是mips的扩展。

目前无论mips还是arm，性能和主流x86差距都很大，不过arm贵在便宜低功耗，mips则纯计算能力很强


## 1.6 RISC与CISC

`CISC`可以翻译为“复杂指令集计算机”，而`RISC`可以翻译为“精简指令集计算机”;  
单片机的诞生就是从CISC的概念开始的；

CISC: 包含丰富的指令集，通过用尽可能少的指令来执行各种过程来提高微型计算机的性能  
RISC: 通过高速执行多个精简指令来提高整个微机的性能


## 1.7 PPC
PowerPC（ Performance Optimization With Enhanced RISC – Performance Computing ）简称PPC是一种精简指令集（RISC）架构的中央处理器（CPU），
其基本的设计源自IBM的POWER（Performance Optimized With Enhanced RISC； “增强RISC性能优化” 架构。

4xx 系列PowerPC 处理器缺乏浮点运算

## 1.8 S390X

IBM System z 系列 (zSeries)大型机 (mainframe) 硬件平台，是银行或者大型企业或者科研单位用的；
