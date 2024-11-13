---
layout: post
title: serialVersionUID
subtitle:
date:       2021-09-27 09:24:06
categories: [JAVA]
tags: [JAVA,serialVersionUID]
---


#
类中的版本控件。
实现过Serializable接口，但没有` serialVersionUID`则必须遇到此警告消息 does not declare a static final serialVersionUID field of type long 

未显式声明serialVersionUID，JVM将根据您的Serializable类的各个方面自动为您执行此操作