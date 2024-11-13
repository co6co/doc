---
layout: post
title: shell
subtitle:
date:       2022-04-26 09:06:55
categories: [Linux]
tags: [Linux,shell]
---


# 1. 符号
## 1.1 参数
 ```
 a1=$n    				#n=1-9
 b10=${n}  				#n>=10
 ```
## 1.2 返回值
```
function demoFun1(){
    echo "这是我的第一个 shell 函数!"
    return `expr 1 + 1`
}
demoFun1
$?              //仅对其上一条指令负责
```
```
if echo "Hello World !" | grep -e Hello    //如果找到了匹配的内容，会打印匹配部分且得到的返回值 $? 为 0，如果找不到，则返回值 $? 为 1
then
    echo true
else
    echo false
fi
```

## 1.10 多行注解

```
#方式1
:<<EOF
...
...
...
EOF

#方式2
:<<'
注释内容...
注释内容...
注释内容...
'

#方式3
:<<!
注释内容...
注释内容...
注释内容...
!

```
# 2. 变量
## 2.1 只读
```

myUrl="https://www.google.com" 
echo ${myUrl}
echo ${#myUrl}						#获取长度	
echo ${#myUrl[0]}					#与上面等价
echo ${myUrl:1:4}					#子串  ttps 
echo `expr index "$myUrl" oo`		# 查找子串位置 14 从1开始
readonly myUrl  
myUrl="https://www.runoob.com"
echo ${myUrl}
unset myUrl         				#删除变量
echo $myUrl							#没有任何输出
```
## 2.2 数组
```
array_name=(value0 value1 value2 value3)
array_name[0]
echo ${array_name[0]}			#${数组名[下标]}
echo ${array_name[@]}			#获取数组所有元素

# 取得数组元素的个数
length=${#array_name[@]}
# 或者
length=${#array_name[*]}
# 取得数组单个元素的长度
lengthn=${#array_name[n]}
```


# 3. 运算符
## 3.1 算术运算符
|符号|名称|说明|
|--|--:|:--|
|+	|加法	  | `expr $a + $b` 结果为 30。|
|-	|减法	  | `expr $a - $b` 结果为 -10。|
|*	|乘法	  | `expr $a \* $b` 结果为  200。|
|/	|除法	  | `expr $b / $a` 结果为 2。|
|%	|取余	  | `expr $b % $a` 结果为 0。|
|=	|赋值	  |  a=$b 把变量 b 的值赋给 a。|
|==	|相等。   | 用于比较两个数字，相同则返回 true。	[ $a == $b ] 返回 false。|
|!=	|不相等。 |  用于比较两个数字，不相同则返回 true。	[ $a != $b ] 返回 true。|
```
 
val=`expr $b % $a`
echo "b % a : $val"

if [ $a == $b ]
then
   echo "a 等于 b"
fi
if [ $a != $b ]
then
   echo "a 不等于 b"
fi
```
## 3.2 关系运算符

|符号|说明|
|--|:--|
|-eq |	检测两个数是否相等，相等返回 true。	[ $a -eq $b ] 返回 false。|
|-ne |	检测两个数是否不相等，不相等返回 true。	[ $a -ne $b ] 返回 true。|
|-gt |	检测左边的数是否大于右边的，如果是，则返回 true。	[ $a -gt $b ] 返回 false。|
|-lt |	检测左边的数是否小于右边的，如果是，则返回 true。	[ $a -lt $b ] 返回 true。|
|-ge |	检测左边的数是否大于等于右边的，如果是，则返回 true。	[ $a -ge $b ] 返回 false。|
|-le |	检测左边的数是否小于等于右边的，如果是，则返回 true。	[ $a -le $b ] 返回 true。|

```
a=10
b=20

if [ $a -eq $b ]
then
   echo "$a -eq $b : a 等于 b"
else
   echo "$a -eq $b: a 不等于 b"
fi
```
## 3.3 布尔运算符
|符号|说明|
|--|:--|
|!	|非运算，表达式为 true 则返回 false，否则返回 true。	[ ! false ] 返回 true。|
|-o	|或运算，有一个表达式为 true 则返回 true。	[ $a -lt 20 -o $b -gt 100 ] 返回 true。|
|-a	|与运算，两个表达式都为 true 才返回 true。	[ $a -lt 20 -a $b -gt 100 ] 返回 false。|

```
if [ $a -lt 100 -a $b -gt 15 ]
then
   echo "$a 小于 100 且 $b 大于 15 : 返回 true"
else
   echo "$a 小于 100 且 $b 大于 15 : 返回 false"
fi
```

## 3.4 逻辑运算符
|符号|说明|
|--|:--|
| `&&`	|`逻辑的 AND	[[ $a -lt 100 && $b -gt 100 ]] 返回 false`|
| &#124;&#124;	|`逻辑的 OR	[[ $a -lt 100 || $b -gt 100 ]] 返回 true `|
```



if [[ $a -lt 100 && $b -gt 100 ]]
then
   echo "返回 true"
 
else
   echo "返回 false"
fi
```
## 3.5 字符串运算符
|符号|说明|
|--|:--|
|=	|检测两个字符串是否相等，相等返回 true。	[ $a = $b ] 返回 false。|
|!=	|检测两个字符串是否不相等，不相等返回 true。	[ $a != $b ] 返回 true。|
|-z	|检测字符串长度是否为0，为0返回 true。	[ -z $a ] 返回 false。|
|-n	|检测字符串长度是否不为 0，不为 0 返回 true。	[ -n "$a" ] 返回 true。|
|$	|检测字符串是否为空，不为空返回 true。	[ $a ] 返回 true。|


## 3.6 文件测试运算符
|符号|说明|
|--|:--|
|-b file	|检测文件是否是块设备文件，如果是，则返回 true。	[ -b $file ] 返回 false。|
|-c file	|检测文件是否是字符设备文件，如果是，则返回 true。	[ -c $file ] 返回 false。|
|-d file	|检测文件是否是目录，如果是，则返回 true。	[ -d $file ] 返回 false。|
|-f file	|检测文件是否是普通文件（既不是目录，也不是设备文件），如果是，则返回 true。	[ -f $file ] 返回 true。|
|-g file	|检测文件是否设置了 SGID 位，如果是，则返回 true。	[ -g $file ] 返回 false。|
|-k file	|检测文件是否设置了粘着位(Sticky Bit)，如果是，则返回 true。	[ -k $file ] 返回 false。|
|-p file	|检测文件是否是有名管道，如果是，则返回 true。	[ -p $file ] 返回 false。|
|-u file	|检测文件是否设置了 SUID 位，如果是，则返回 true。	[ -u $file ] 返回 false。|
|-r file	|检测文件是否可读，如果是，则返回 true。	[ -r $file ] 返回 true。|
|-w file	|检测文件是否可写，如果是，则返回 true。	[ -w $file ] 返回 true。|
|-x file	|检测文件是否可执行，如果是，则返回 true。	[ -x $file ] 返回 true。|
|-s file	|检测文件是否为空（文件大小是否大于0），不为空返回 true。	[ -s $file ] 返回 true。|
|-e file	|检测文件（包括目录）是否存在，如果是，则返回 true。	[ -e $file ] 返回 true。|
|||
|-S:        |判断某文件是否 socket。|
|-L:        |检测文件是否存在并且是一个符号链接。|
 


# 4. 命令
## 4.1 echo
```
echo -e "OK! \c" # -e 开启转义 \c 不换行
echo "It is a test"

echo '$name\"'   #原样输出字符串 $name\"
echo `date`		 #显示执行结果


```

## 4.2 test 检查某个条件是否成立
```
if test $[num1] -eq $[num2]
then
    echo '两个数相等！'
else
    echo '两个数不相等！'
fi
```

## 3.3 重定向
|命令|描述|
|--|--|
|command > file	|将输出重定向到 file。|
|command < file	|将输入重定向到 file。|
|command >> file|	将输出以追加的方式重定向到 file。|
|n > file	|将文件描述符为 n 的文件重定向到 file。|
|n >> file	|将文件描述符为 n 的文件以追加的方式重定向到 file。|
|n >& m	|将输出文件 m 和 n 合并。|
|n <& m	|将输入文件 m 和 n 合并。|
|<< tag	|将开始标记 tag 和结束标记 tag 之间的内容作为输入。|

如果希望执行某个命令，但又不希望在屏幕上显示输出结果，那么可以将输出重定向到 /dev/null：
`command > /dev/null`

dev/null 是一个特殊的文件，写入到它的内容都会被丢弃；如果尝试从该文件读取内容，那么什么也读不到。但是 /dev/null 文件非常有用，将命令的输出重定向到它，会起到"禁止输出"的效果。
如果希望屏蔽 stdout 和 stderr，可以这样写：`$ command > /dev/null 2>&1`
```
0 :标准输入（STDIN）
1 :是标准输出（STDOUT）
2 :是标准错误输出（STDERR）。
```
这里的 2 和 > 之间不可以有空格，2> 是一体的时候才表示错误输出。



## 4.4 shift
 shift命令左移。比如 shift 3表示原来的 $4现在变成 $1，原来的 $5现在变成 $2等等，原来的 $1、 $2、 $3丢弃， $0不移动。不带参数的 shift命令相当于 shift 1。
 
 
 # 5 其他
## 5.1 for
```
for file in `ls /etc`
for file in $(ls /etc)
``` 
 