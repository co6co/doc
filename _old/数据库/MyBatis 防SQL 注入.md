---
layout: post
title: MyBatis 防SQL 注入
subtitle:
date:       2021-04-21 14:11:32
categories: [数据库]
tags: [数据库,MyBatis 防SQL 注入]
---


# SQL 注入
## 1.#和$的区别。
这两个符号非常的像Shell中的魔幻符号，但好在只有两种情况。
- `#`  代表的是使用sql预编译方式，安全可靠 就是一个绝对安全的写法。因为整个`#{xx}`会被替换成`?`
- `$` 代表着使用的是拼接方式，**有SQL注入的风险**

## 2. 可能存在SQL注入 
### a. like  **使用concat**
```
SELECT * FROM user WHERE name like '%#{name}%'  //会报语法错
SELECT * FROM user WHERE name like '%${name}%'  //可以运行

SELECT * FROM user WHERE  name like concat('%',#{name}, '%') //正确的写法
```

### b. IN 语句 foreach
```
SELECT * FROM user WHERE id in (#{ids}) //报错
SELECT * FROM user WHERE id in (${ids}) //可以运行

//正确的写法
 SELECT * FROM user WHERE id in
 <foreach collection="ids" index="index" item="id" open="(" separator="," close=")">
	 #{id}
 </foreach>

```

###  c. order by 白名单
```
SELECT * FROM user order by create_time #{orderByName} //报错
SELECT * FROM user order by create_time ${orderByName} //正常

//orderByName 设置白名单
```