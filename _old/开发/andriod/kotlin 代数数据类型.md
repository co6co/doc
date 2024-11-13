---
layout: post
title: kotlin 代数数据类型
subtitle:
date:       2023-03-17 11:53:24
categories: [andriod]
tags: [andriod,kotlin 代数数据类型]
---


# 1. 代数数据类型（Algebraic Data Type，ADT）
在计算机编程，特别是函数式编程与类型理论中ADT是一种组合类型（composite type）。
例如：一个类型由其他类型组合而成，两个常用的代数类型是“和（sum）”类型与“积(product)”类型。

ADT就是像代数一样的数据类型，简单理解就是能代表数字的符号.
```
x+5=6
y*3=21
```
通过解方程：代数x代表1，代数y代表7，两个操作符+*，通过代数和这些操作符能做什么？
```
x*1=z
a+2=c
```
第一个表达式中代数x与1通过乘法操作得到一个新的代数z，
第二个表达式中代数a与2通过加法操作得到了一个新的代数c，

思考一下，如果把上面的表达式中的代数与数字换成编程语言中的**类型或值**，那他们之间通过某种操作是不是就可以得到某种新的类型；

当我们将这些代数或者数字换成类型，那么这种被我们用代数或者数字换成的类型，以及通过这些类型所产生的新类型就叫作代数数据类型ADT；

## 1.1. ADT应用
ADT的应用很广，对于我们熟知的业务，我们可以将一些比较简单的类型通过某种“操作符”而抽象成比较复杂而功能强大的类型。

在编程语言中，某些常用的类型其实就是代数类型，比如枚举类，ADT是类型安全的，使用它可以为我们免去许多麻烦。

前面介绍的代数只是一些初等代数，代数是一个很庞大的数学分支，从简单的线性、多项式代数到环、域、再到范畴、函子等更加抽象的代数，
越往后发展，代数的抽象级别就越高，同时也接近事物的本质，当然其刻画事物的能力也越强。
函数式编程思想；它的很多语法特性就是利用了范畴论中某些思想来实现的；

在日常开发中，如果能够合理利用ADT去对业务进行高度抽象，那么我们的代码在能够实现诸多功能的前提下还会变得非常简洁；

## 1.2. 计数
Kotlin中的Unit，是一种相比JAVA 新引入的类型，对Unit类型进行计数，Unit表示只有一个实例，它只有一种取值，
所有如果采用计数的方式，Unit对应的就是数字1；

有了计数的概念，我们就比较容易理解ADT常见的两种类型：积类型(Product)与和类型(Sum);

## 1.3. 积类型
积类型，想到乘法，两个数相乘的结果为积，在ADT中，积类型的表现形式与乘法类似，
我们可以将其理解为一种组合(Combination),比如这里有一个类型a，还有个类型b，那么我们应该怎么组合成一个积类型c，
在计数的概念，将每种类型与数字关联，那么积类型c应该：
```
c=a*b
```

我们指定Boolean类型对应的是2，Unit类型对应的是1，那么它们组合之后产生的积类型应该就是：
```
2*1=2
```
用实际的代码来表达这两种类型的组合：
```
class BolleanProductUnit(a:Boolean,b:Unit){}
```

上面存在一个类型为Boolean的参数及一个Unit的参数b，
这个类的实际取值：
```
val a=BooleanProductUnit(false,Unit)
val b=BooleanProductUnit(false,Unit)
```
上面最多有两种取值，符合我们的猜想，当我们在利用类进行组合时，实际上就是一种product操作，
积类型可以看作同时持有某种类型的类型。

我们可以根据计数来判断某种类型或者某种类的取值，所有计数还能用在编译时期对when之类的语句做分支检查；

## 1.4.和类型与密封类
和类型对应的代数中的加法，枚举类可以算是一种和类型

通过一个枚举类Day，包含一个星期所有天的定义，为什么它是和类型呢，这里可以通过前面的计数方式进行验证；
枚举中每个常量都是一个对象，它（枚举中的一个对象）与其他常量一样，只是有一种取值，我们将其计为1，
枚举类Day的取值总数为：`1+1+1+1+1+1+1=7`

SUM类型的特点：
- 是类安全的，因为它是一个闭环，如DAY，我们指定它总共有7中可能的取值，所有当使用它不用担心出现非法情况；
- 是一种 OR 的关系，积类型是一种 AND 的关系；

和类型在使用的时候功能比较单一，扩展性不强，我们需要有一种在表达上更强大的语法，那就是密封类；
```
sealed class Day{
	class SUN:DAY()
	class MON:DAY()
	...
	class SAT:DAY()
}
```

Day 也只有7中可能的取值，密封类会通过一个sealed修饰符将其创建的子类进行限制，即**密封类的子类只能定义在父类或者与父类同一个文件内**；
当我们使用when表达式时不用去考虑非法的情况，也就是可以省略else分支，因为和类型时安全的

## 1.5. 构造代数数据类型
分析简单例子，介绍如何构造ADT：

求面积：
- 圆（给定半径）
- 长方形（给定长和宽）
- 三角形（给定底和高）

将上面的图形抽象成ADT，首先找到他们的共同点（他们都是几何图形Shape），
然后利用密封类进行抽象：
```
sealed class Shape{
	class Circle(val radius:Double):Shape{}
	class Rectangle(val width:Double,val height:Double):Shape{}
	class Triangle(val base:Double,val heidth:Double):Shape{}
}
```

整个Shape就是一个和类型，其中的Circle，Rectangle、Triangle就是通过将基本类型Double构造成类而组合成积类型；
可以放心使用when表达式去求各个形状的面积；
```
fun getArea=(shape:Shape):Double=when(shape){
	is Shape.Circle->Match.PI*shape.radius*shape.radius
	.....
}
```


# 2. 模式匹配（Pattern matching）
模式其本质就是**表达式**，模式匹配所匹配的内容也就是表达式，所以当我们在构造模式时就是在构造表达式，
可以将模式构造成简单的数字、逻辑表达式，也可以构造成复杂的类型或者其他嵌套的结构；
```
//不是正常的代码
fun temp=(a:any)=when{ 	 
	1-> "it is 1"		 //常量模式
	is Shape.Triangle-> shape.base*shape.height/2.0 //类模式
	a in 2..11->(a.toString())  //逻辑表达式模式
	a.contains("Yes")-> a 		//逻辑表达式
	else -> "else"

}
```

上面的模式也可以用if-else或者switch-case来实现， 
哪种模式在使用if-else 等语句来实现会很苦恼呢---嵌套模式

```
sealed class Expr{
	data class Num(val value:Int):Expr()
	//一种树形结构
	//opName = +
	data class Operate(val opName:String,val left:Expr,val right:Expr):Expr
}
```

利用上面的结构实现：进行整数表达式的计算： **0+x =x 或者 x+0 =x**
```
//伪代码：
if (expr is "0+x" || expr is "x+0") x else expr
```

```
fun simplifyExpr(expr:Expr):Expr=when {
	(expr is Expr.Operate)&& (expr.opName=="+")&& (Expr.left is Expr.Num) &&  (Expr.right is Expr.Num)  &&  (Expr.left == 0)   Expr.right
	(expr is Expr.Operate)&& (expr.opName=="+")&& (Expr.left is Expr.Num) &&  (Expr.right is Expr.Num)  &&  (Expr.right == 0)  Expr.left 
	else ->expr
}
```