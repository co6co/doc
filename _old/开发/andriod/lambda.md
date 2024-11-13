---
layout: post
title: lambda
subtitle:
date:       2023-03-20 15:48:14
categories: [andriod]
tags: [andriod,lambda]
---


# 1. Lamdba
在Kotlin的集合操作库中Lambda已经被广泛使用，集合操作中使用Lambda会使得代码变得非常简洁和优雅，
但这种简洁和优雅会带来一些额外的开销；

Kotlin拥有真正的函数类型，这使相比JAVA8在支持和实现Lambda语法上更有优势；

setOnclickListenter 是java中的一个`函数式接口`,Kotlin 允许对java的类做一些优化，任何函数接收了一个Java的
SAM(单一抽象方法)都可以用Kotlin的函数进行替代，
```
fun setOnclickListenter(listener:(view)->Unit)
//简化
fun setOnclickListenter{}
```

## 1.1 带有接收者的Lambda
```
val sum:Int.(Int)->Int={other->plus(other)}

//2.sum(1)
```

Kotlin有中神奇的语法-- 类型安全构造器，
用它可构造类型安全的HTML代码，带接收者的LAMBDA语法可以很好地应用其中：
```
class HTML{
	fun body(){}
}
fun html(init:HTML.()->Unit):HTML{
	val html=HTML()
	html.init()
	return html;
	
}
html{
	body()
}
```

## 1.2 with 和 apply
在写Lambda时，省略对象名

```
inline fun  <T,R> with(receiver:T,block:T.()->R):R
```
with第一个参数为接收者类型，第二个参数创建这个类型的block方法；

```
inline fun <T> T.apply(block:T.()->Unit):T
```
与With函数不同，
apply直接被申明为类型T的一个扩展方法，他的Block参数是一个返回Unit类型的函数；
with的block可以返回自由的类型，

# 2. 集合的高阶函数API
```
val list=listOf(1,2,3,4,5,6)
val newList=list.map{it*2}
```

`map`就是一个高阶函数，它接收的参数是一个函数，类似的还有filter、filterNot、count等
`sum,sumBy`。

fold是一个非常有用的函数，第一个参数initial(初始值)，第二个参数 operation 是一个函数；
通过for语句来遍历集合中的每个元素，每次都会调用operation函数，该函数有两个参数，一个是上次调用该函数的结果（第一次调用传入initial），
另一个是当前遍历到的集合元素。fold很好的利用了递归的思想。
reduce与fold类似，维一区别没有初值；

flatMap、flatten 集合嵌套。

## 2.1 惰性集合
```
val list=listOf(1,2,3,4,5)
list.filter{it>2}.map{it*2}
```
当数据超过10万，显得比较低效，
filte和map方法都会返回一个新的集合。为解决这个问题序列（Sequence）就出现了
```
list.asSequence().filter{it>2}.map{it*2}.toList()
```
使用序列时，filter方法和map操作都没有创建额外的集合；
序列中元素的求值是惰性的，意味着利用序列进行链式求值时，不需要像普通集合那样，每进行一次求值操作就产生一个新的集合保存中间数据；

**惰性求值(Lazy Evaluation)** 表示一种在需要时才进行求值的计算方式；表达式不在它被绑定到变量之后就立即求值，而是该值被取用时才去求值；
它可以不仅可以得到性能上的提升，还可构造出一个**无限的数据类型**；

`filter和map` 的返回都是序列，将这类操作成为**中间操作**，`toList`将这类操作成为**末端操作**；

- 中间操作
	再对普通集合进行链式操作，有些操作会产生中间集合，当用这类操作对序列进行求值时，他们就被称为中间操作；
- 末端操作
	末端操作就是一个返回结果的操作，他的返回值不能是序列，必须是一个明确的结果；
 
 - 序列可以是无限的
 ```
 //自然数
 val naturalNumList=generateSequence(0){it+1}
 //取出前10个自然数
 naturalNumList.takeWhile{it<=9}.toList()
 
 ```
 
 我们不能将一个无限的数据结构通过穷举的方式呈现出来，而只能实现一种表示无限的状态，
 让我们在使用时感觉它是无限的。
 
## 2.1.1 java8中stream

```
students.stream().filter(it->it.sex=="m").collect(toList());
```
相比Kotlin序列 首先将集合转换为steam，最后将stream转换为list；java8 中的流和Kotlin中的序一样，也是惰性求值。

Stream是一次性的，这与迭代器很相似；Stream能够在多核架构上并行地进行流处理；
```
student.paralleStream().filter(it->it.sex=="m").collect(toList());
```

# 3. 内联函数
Kotlin使用Lambda 会带来一些额外的开销， 内联函数之所以被设计出来主要是优化Kotlin支持lambda表达式之后所带来的开销；
在java中并不需要特别关注这个问题，在JAVA7之后，JVM引入了一种叫做**invokedynamic技术**，会帮助我们做Lambda优化；

Kotlin中每声明一个Labmda表达式，都会在字节码中产生一个匿名类，该匿名类包含了一个invoke方法，作为Lambda的调用方法，
每次调用时还会创建新的对象；
Android主要采用JAVA6为主要的开发语言，Kotlin要在Android中引入Lambda语法，必须采用某种方式了优化Lambda带来的额外开销。

## 3.1 invokedynamic
Java如何解决上述问题的，与Kotlin这种在编译期通过硬编码生成Lambda转换类的机制不同，
JAVA在SE7之后通过invokedynamic技术实现了在运行期间产生相应的翻译代码；
在invokedynamic首次被调用的时候，触发产生一个匿名类来替换中间码invokedynamic，
后续调用会直接采用这个匿名类的代码：
- 由于具体的转换实现是在运行时产生的，在字节码中能看的是有一个固定的invokedynamic，所有需要静态生成类的个数及字节码大小都显著减少；
- 与写死在字节码的策略不同，利用invokedynamic可以把实际的翻译策略隐藏在JDK库中实现，极大提高了灵活性，确保向后兼容的同时后期可继续对翻译策略不断优化升级；
- JVM天然支持针对该方式的Lambda表达式的翻译和优化，开发者可以完全不必关系这个问题；

## 3.2 inline
Android最主流的JAVA版本是SE6 ，这导致无法通过invokedynamic来解决Android平台的Lambda开销问题；
内联函数作为另一种主流的解决方案，内联函数的函数体在编译期，被嵌入每一个被调用的地方，减少额外生成匿名类的书，及函数执行的时间开销；

```

fun foo(block:()->Unit){
	println("before block")
	block()
	println("end block")
}

fun main(){
	foo{println("...")}
}

```

调用foo就会生成一个Function0类型的block类，然后通过invoke方法执行，
这样会增加额外的生成类和调用开销；

在foo 方法中增加 `inline` 修饰符；foo函数体代码及变调用的Lambda代码都粘贴到相应调用的位置；

### 3.2.1 内联函数不是万能
- JVM 对普通函数已经能够根据实际情况只能判断是否进行内联优化，所有我们并不需使用inline 语法，那只会让字节码变得更复杂；
- 尽量避免对大量函数体的函数进行内联，这样会导致过多的字节码；
- 内联函数，不能获取闭包类的私有成员，除非把他们申明为internal

noinline 避免参数被内联；

### 3.2.2 特效
非局部返回和具体化参数类型；
#### 3.2.2.1 非局部返回
 
```
fun foo(returning:()->Unit){
	pringln("before")
	returning()
	pringln("after")
}

foo{return }
//编译出错
```
**正确情况下 LAMBDA表达式不允许存在return关键字**;

**使用inline实现Lambda非局部返回**

将foo内联 `inline fun foo ....` 编译顺利通过，Lambda的return执行后直接让 foo 函数退出执行；

**使用标签实现Lambda非局部返回**
```
foo{return@foo }
// 结果
before
```
非局部返回尤其在循环控制显得特别有用，Kotlin中的forEach接口，由于它也是内联函数，我们可以在它调用的Lambda中执行return 退出上层的程序；
```
fun hasZeros(list:List<Int>):Boolean{
	list.forEach{
		if(it==0) return true //直接返回foo函数结果
	}
	return false
}

```

非局部返回某些场合非常有用，但可能也存在风险，
因为内联函数所接收的Lambda参数常常来自**上下文的其他地方**，
为了避免带有return的Lambda参数产生破坏，我们使用`crossinline`关键字来修饰该参数，从而杜绝此类问题的发生；
```

fun foo(crossinline returning:()->Unit){
	...
}
foo{return }

// 运行结果
Error： return is not allowed here
```

#### 3.2.2.2 具体化参数类型
有由于运行时的类型擦除，我们并不能直接获取一个参数的类型，内联函数会直接在字节码中生成相应的函数体实现，这种情况我们反而可以获得参数具体类型；
```
getType<Int>()

inline fun <reified T> getType(){
	println(T::Class)
}
//
class kotlin.Int
```

androd startActivity可以简写为：
```
inline fun <reified T: Activity> Activity.startActivity( ){
    var intent=Intent(this,T::class.java)
    this.startActivity(intent)
}
```