---
layout: post
title: oracle
subtitle:
date:       2021-11-18 17:17:40
categories: [数据库]
tags: [数据库,oracle]
---


https://www.iteye.com/blog/kylinsoong-776654


# 数据库
```
SQL> sqlplus /nolog  
SQL> conn USER/PASSWORD as sysdba  


#SQL>  sqlplus "/as sysdba"


SQL> startup nomount  

SQL> alter database mount;  
SQL> alter database open;
SQL> startup  




# 其他

SQL> shutdown immedate;
SQL> startup mount;

SQL> shutdown
数据库已经关闭。
已经卸载数据库。
ORACLE 例程已经关闭。
SQL> startup
ORACLE 例程已经启动。


```