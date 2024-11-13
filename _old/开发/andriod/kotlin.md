---
layout: post
title: kotlin
subtitle:
date:       2023-02-02 09:27:12
categories: [andriod]
tags: [andriod,kotlin]
---



# 1. Kotlin
Java代码确实是要先编译再运行的，但
是Java代码编译之后生成的并不是计算机可识别的二进制文件，而是一种特殊的class文件，这
种class文件只有Java虚拟机（Android中叫ART，一种移动优化版的虚拟机）才能识别，而这
个Java虚拟机担当的其实就是解释器的角色，它会在程序运行时将编译后的class文件解释成计
算机可识别的二进制数据后再执行，因此，准确来讲，Java属于解释型语言。

其实Java虚拟机并不直接和你编写的Java代码打交道，而是和编译之后生成的class文件打交道
kotlin：一门新的编程语言，然后自己做了个编译器，让它将这门新语言的代码编译成同样规格的class文件

危害Android官方支持的开发语言为Kotlin:
 1. 说Kotlin的语法更加简洁，对于同样的功能，使用Kotlin开发的代码量可能会比使用Java开发的减少50% 甚至更多
 2. Kotlin的语法更加高级，相了很多工夫，几乎杜绝了空指针这个全球崩溃率最高的异常
 4. 它和Java是100%兼容的 (可以直接调用使用Java编写的代码，也可以无缝使用Java第三方的开源库)
 

Kotlin 是基于Java 6实现的；
## 1.1 变量和函数
val【value的简写】 申明一个不可变的变量 相当于java 的final； 引用不可变，但不意味着引用对象不可变
var【variable简写】
kotlin 的每一行不用加 `;`
类型推导；如果需要后面赋值，`var a: Int`
Kotlin 完全抛弃了Java的基本数据类型，全部使用对象数据类型；

**尽可能采用val，不可变对象及纯函数来设计程序[没有副作用域的]**
防御性的编码思维模式
## 1.2 函数
```
fun methodName(param1:Int,param2:Int):Int{
	return 0
}
```

## 1.3 语法糖
函数只有一行代码时 ---> 不必编写函数体，直接将唯一代码写在函数定义的尾巴中间用等号连接
```
fun largerNumber(num1:Int,num2:Int):Int =max(num1,num2)
等号足以表单返回的意思，因此return可以省略，
Kotlin有推到机制，返回类型可以不用熟悉
fun largerNumber(num1:Int,num2:Int) =max(num1,num2)
```

## 1.4 控制语句
### 1.4.1 if
if 语句于java完全一致，另外增加了一些额外的功能：
```
var value=if(num1>num2){
	num1
} else {
	num2
}
//某个条件最后一行代码作为返回值；
fun largerNumber(num2:Int,num2:Int)=if(num1>num2)num1 else num2
```

### 1.4.2 when
when 类似于java 中的switch 但比switch强大得多；
 ```
 fun getScore(name:String)= when(name){
	"Tom" -> 86
	"JIM" ->72
	else ->0
	//匹配值 ->{执行逻辑}
 }
 //类型控制  == java instanceof
 fun checkNumber(num:Number){
	when(num){
		is Int ->println("Int")
		is Double ->pringln("double")
		else -> println("不支持")
	}
 }
 //
 //不带参数得 when
 fun getScore(name:String)=when{
	name.startWith("Tom") -> 80  
	name == "JIM" ->70
	else ->0
 }
 ```
 kotlin 中 判断对象是否相等可以直接使用 `==`
 
 ### 1.4.3 循环
 while 与java 无区别,
 java 中 `for -i` 被 Kotlin 舍弃, java 中得 for-each 变成了 `for-in`,
 
 区间：`val range=0..10`  等同于数据中得[0,10];
 `..`创建两端闭区间得关键字
 ```
 for (i in 0..10){
	println(i)
}
 ```
`var range=0 until 10` 定义左闭右开区间`[0,10)`；
 ```
 for (i in 0 until 10 step 2){
	println(i)
 }
 ```
 `var 10 downTo 1`   定义[10,1] 降序区间
 
 
 ## 1.5 其他
 ### 1.5.1  `?:`
 Kotlin 没有采用三元运算符，`?:` 必须放在一起，被叫做 Elvis 运算符或者null合并运算符；
 **用来给可空类型的变量指定为空情况下的值**
 
 非空断言!!
 val result=student!!.glasses
 
 !is 和 as?
 
 ### 1.5.1  中缀表达式
`in` `step` `downTo` `until`
```
infix fun<A,B> A.to(that:B):Pair<A,B>
//使用 方式 A 中缀方法 B

```
 
 定义中缀表达式必须满足：
 - 函数必须是某个类型的扩展函数或者成员方法；
 - 中缀函数只能由一个参数；
 - Kotlin函数支持默认参数，但中缀函数不能有默认值，

中缀函数在成员方法
```
class Person{
	infix fun called(name:String){
		print("My name is ${name}")
	}
}

//
val p=Person()
p called "Shaw"
p.called("shaw") //仍支持使用普通方法调用
```
 
### 1.5.2 可变参数
 `varargs` 定义函数中的可变参数 类似于java 中的 `...`, java 中可变参数必须是最后一个参数，在 Kotlin 没有限制；
 可以使用 `*` 来传入外部变量作为可变参数：
 ```
  fun printLetters(vararg letters:String,count:Int):Unit{
	print("${count} letters are")
	for(letter in letters) print(letter)
  }
 
  printLetters("a","B","C",count=3);
  val letters=arrayOf("a","b","c")
  printLetters(*letters,count=3); //使用* 传入外部变量作为可变参数
 ```
 
 ### 1.5.3 字符串的API
 ```
 "".isEmpty() //true
 " ".isEmpty() //false
 " ".isBlank() //true
 "abcdefg".filter{c-> c in 'a'..'d'} //abcd
 ```
 
 原生字符串 三个引号
 val rawString="""
 \n 转义字符已 原样打印
 \n"""
 
 ### 1.5.4 相等
 - 结构相等 `==` 不相等 `!==`
 - 引用相等 `===` 不相等`!===`
 - 比较运行时的原始类型 比如 Int 那么 `===` 等价于 `==`
 
### 1.5.4 延迟初始化
lateinit 和 by lazy
```
class Bird(val weight,val age:Int,val color:String){
	val sex:String by lazy{
		if(color=="yellow") "male" else "female"
	}
}
```

by lazy 语法特点：
- 变量必须**引用不可变**，
- 首次调用才会执行，一旦赋值后，不能被更改；
- 默认有同步锁，线程安全

```
val sex:String by lazy (LazyThreadSafetyModel.PUBLICATION){
	//并行模式
	...
}
val sex:String by lazy (LazyThreadSafetyModel.NONE){
	//不做任何线程包含/不会有任何线程开销
	...
}
```

与lazy 不同，lateinit 主要用于var声明的变量（不能用于基本数据类型如Int ，需要使用Inter封装类）；
基本数据类型延迟：
```
var test by Delegates.notNUll<Int>()

fun doSomething(){
	test =1
}
```

 # 2. 面向对象
 Konlin 中 任何一个`非抽象类`默认都是`不可以被继承`的,相当于java 中 类申明了 final关键字；
 如果一个类不是专门为继承而设计的，那么就应该主动将它加上final声明，禁止它可以被继承

```
//open 允许继承
open class Person  //-java->public class Person
class Student :Person() {}
```
Kotlin 中得构造函数有两种：
- 主构造函数 （仅一个）
	特点时没有函数体
	主构造函数声明的参数 自动成为改类的字段
	```
	Student(val sno:String,val grade:Int):Person(){
		int{
			...//逻辑代码
		}
	}
	```
- 次构造函数 （可多个）
	可用用来实例化类（与主构造函数类似）
	通过`contructor` 定义，必须调用(直接或间接)主构造函数
```
class Student(val sno:String ,val grade :Int,name :String ,age:int):Person(name,age){
	constructor(name:String,age:Int):this("",0,name,age)
	constructor():this("",0)
}
//下面定义被允许
// 类没有显示定义主构造函数且定义了次构造函数
// 没有主构造函数, 继承 person 就不需要加 '()'
// 没有主构造函数，只能直接调用父类的构造函数
class Student : Person{
	contructor(name:String,age:Int):super(name,age){}
}
```

Kotlin 除了可以利用final来限制一个类的继承，还可以通过密封类的语法来限制一个类的继承；
密封类若要继承则需要江子类定义在同一个文件中；
这种方式有他的局限性，即它不能被初始化，因为它背后是基于一个重新类实现的；
```
sealed class Bird{
	open fun fly()="I can fly"
	class Eagle:Bird()
}

=java=>
public abstract class Bird{
	public String fly(){
		return "I can fly";
	}
	private Bird(){}
	....
	pbulic static final class Eagle extends Bird{
		public Eagle(){
			super();
		}
	}
}
```

密封类的使用场景有限，它可以看成一种功能更强大的枚举，
所有它在模式匹配中可以起到很大的作用；

## 2.1. 接口
 
Kotin 中的 `':' == extends + implement == C#中的 ':'`
如果接口中有函数体等于有默认实现；
kotlin中的修饰符：public(默认)、 private 、protected 和 internal;
protected java中当前类子类统包类下可见，Kotin中当前类和子类可见；
internal 同一模块 等同于java 中默认修饰符default， 作用域是包内可以访问；

在Java中类中很少见private 修饰的类，因为在java中的类或方法没有单独属于某个文件的概念；
创建的java 文件，里面的类要么是public要么是包私有，而没有只属于这个文件的概念；
若要用private修饰，这个只能是其他类的内部类。

在Kotlin中则可以用private给单独的类修饰，它的作用域就是当前这个Kotlin文件。


## 2.2 Lamdba
`listOf()` 函数创建的是一个不可变的集合 `mutableListOf()` 可变集合 `setOf()`  Set集合中是不可以存放重复元素的。

 ```
	val map = HashMap<String, Int>()
	map["Apple"] = 1
	map["Banana"] = 2
	//mapOf()和mutableMapOf()
	val map = mapOf("Apple" to 1, "Banana" to 2, "Orange" to 3, "Pear" to 4, "Grape" to 5)
	//遍历 for ((fruit, number) in map) 
 ```
 
 ### 2.2.1 集合式API
 ```
 val list=listOf(....)
 val maxLength=list.maxBy{it.lentgh};
 ===
 val lambda={s:String->s.length}
 val maxLength=list.maxBy(lambda); 
 ```
 
 推到过程
 ```
 val maxLength=list.maxBy({s:String->s.length});
 ====>Kotlin 规定 当 lanbda 参数为函数的最后一个 参数 可以将 lambda表达式移到'()'外面
 val maxLength=list.maxBy(){s:String->s.length};
 ====> 是唯一参数 可以省略 '()'
 val maxLength=list.maxBy {s:String->s.length};
 ====> 推导机制 省略参数类型
 val maxLength=list.maxBy {s->s.length};
 ====> lanbda 的参数列表只有一个参数，可以不必什么参数名
 val maxLength=list.maxBy {s.length};
```

 其他：
```
 //过滤 + 转 大写
 list.filter{it.length<=5}.map{it.toUpperCase()}
 
 list.any {it.length<=5} // 至少存在一个
 list.all {it.length<=5} // 所有元素
 ```
 
 ### 2.2.2 调用JAVA中的函数式API
 ```
 public interface Runnable{
	void run();
 }
 
 new Thread(new Runnable(){
	@Override
	public void run(){
		pringln("Thread is Running");
	}
 }).start();
 ```
 对于java方法，只要接收 Runnable参数，就可以使用函数式API，
 将上面的代码翻译为Kotlin版本：
 ```
 Thread(object :Runnable{
	override fun run(){
		pringln("Thread is Running")
	}
 }).start()
 ====> Thread 类符合 JAVA函数式API的使用条件,Runnable类中只有一个待实现的方法，没有显示重写run(),Runnable后面的表达式就是run实现的内容
 
 Thread(Runnable{
	pringln("Thread is Running")
 }).start()
 
 ====> 参数列表仅有一个java单抽象方法接口参数，可省略接口名
   Thread( { pringln("Thread is Running") }).start()
 ```
 ====> Lamdba 是方法的最后一个参数可以 移动到'()' 外面， 且 Lambda是方法的唯一参数 可以省略 ’()‘
  Thread { pringln("Thread is Running") }.start()
  
  
 # 3. 空指针检查
 用编译时判空检查的机制几乎杜绝了空指针异常。
 ```
 //Kotlin默认所有的参数和变量都不可为空
 fun doStudy(study: Study) {
	 study.readBooks()
	 study.doHomework()
 }

 //可为空的类型系统
 fun doStudy(study: Study?) {
	 study.readBooks() //出现了一个红色下滑线的错误提示
	 if(study!=null) {
		study.doHomework() //判断之后才能通过
	 }
	 study?.doHomework() //简写 //判空辅助工具 
	 study = study ?: Study()
 }
 
 fun getTextLength(text: String?) = text?.length ?: 0
  // ?.  text ==null  返回 null 
  // ?:  返回 0
 
  // 告诉 编译器 content  不会为 空 ，实际中还是有 空风险
  val upperCase = content!!.toUpperCase()
  
  
  study?.readBooks()
  study?.doHomework()
  == 两个 if 表达 有些啰嗦
  
  //对象不为空时 用 let函数
  study?.let { stu->
	stu.readBooks()
	stu.doHomework()
  }
  study?.let{
	it.readBooks()
	it.doHomework()
  }
  
  //let函数是可以处理全局变量的判空问题的
  //而if判断语句则无法做到这一点
  //如果 study 变为全局 ，if 函数判断语句会提示错误， let函数则正常工作
  //因为 全局都可能修改 study 仍有空风险
 ```
 
 ```
 fun onCreate=context?.let {
     dbHelper = MyDatabaseHelper(it, "BookStore.db", 2)
     true
 } ?: false
```
综合利用了Getter方法语法糖、?.操作符、let函数、?:操作符以及单行代码函数语法糖
- `getContext()`方法并借助?.操作符和let函数判断它的返回值是否为空
- 如果为空就使用?:操作符返回false 
- 如果不为空就执行let函数中的代码 然后返回true
- 借助了多个操作符和标准函数在一行表达式内完成符合单行代码函数的语法糖要求，所以直接用等号连接返回值即可
 
 # 4. 标准库和静态方法
 标准库函数是在Standard.kt 文件中定义的函数
 
 ## 4.1 with
 第一个参数： 任意类型的对象(上下文)；
 第二个参数：Lambda ，最后一行代码作为返回值
 ```
	val result=with(obj){
		//obj 上下文
		"value" //返回值
	}
	
	val result= with(StringBuilder()){
		append("start eating fruits.\n")
		for(fruit in list){
			append(fruit).append("\n")
		}
		append("ate all fruits.")
		toString()
	}
	println(result)
 ```
 
 ## 4.2 run
 ```
  val result=StringBuilder().run{
		append("start eating fruits.\n")
		for(fruit in list){
			append(fruit).append("\n")
		}
		append("ate all fruits.")
		toString()
  }
  println(result)
 ```
 
 ## 4.3 apply
 无法指定返回值,只能返回调用对象本身；
 ```
   //result:StringBuilder 
   val result=StringBuilder().run {
		append("start eating fruits.\n")
		for(fruit in list){
			append(fruit).append("\n")
		}
		append("ate all fruits.") 
	}
	println(result.toString())
 ```
 
## 4.4 定义静态方法
### 4.4.1 单例方法
单例类会将整个列中的所有方法都变成 类似静态方法的调用方式；
```
object Util{
	fun doAction(){
		pringln("do Action")
	}
}
```
 
### 4.4.2 companion (伴生对象)
`do Action2 ()` 方法也并不是静态方法，是在Util内部建立一个伴生类，是伴生类的实例方法，
Kotlin 会办证Util类始终只会存在一个伴生类对象；
```
class Util{
	fun do Action1(){
		println("do action1")
	}
	companion object{
		fun doAction2(){
			println("do action2")
		}
	}
}

```

Kotlin确实没有之间定义静态方法的关键字，但提供了一些语法特性来支持类似于静态方法的调用写法

### 4.4.3 静态方法
如果需要真正的静态方法，Kotlin提供两种实现
- 注解
	前面单例类和 伴生对象只是语法的形式上模拟了静态方法的调用，如果在JAVA代码中以静态方法的调用方式去调用，会发现**这些方法不存在**
	而如果我们在**单例类或伴生对象的方法**加上 `@JvmStatic`注解，Kotlin编译器就会将这些方法编译成真正的静态方法；
	成为真正的静态方法，不论是在Kotlin 还是在java 中都可以 使用`Util.doAction2()`来调用。
- 顶层方法
	没有定义在任何类中的方法，Kotlin编译器会将 *顶层方法*全部编译为静态方法
	new->Kotlin File/Class 输入名字’Helper.kt‘，**类型选择File**；
	```
	fun doSomething(){
		pringln("doSomethine")
	}
	```
	在Kotlin中 之间调用 `doSemething()`,在java中，Kotlin编译器会自动船舰一个叫做 HelperKt的java类，因此调用`HelperKt.doSemething()`

## 4.5 延迟初始化和密封类
类中存在很多全局变量实例，为了保证它们能够满足Kotlin的空指针检查语法标
准，你不得不做许多的非空判断保护才行，即使你非常确定它们不会为空。
是对全局变量进行延迟初始化。 
延迟初始化使用的是lateinit关键字，它可以告诉Kotlin编译器，我会在晚些时候对这个变量
进行初始化，这样就不用在一开始的时候将它赋值为null了。

```
class MainActivity : AppCompatActivity(), View.OnClickListener {
 //private var adapter: MsgAdapter? = null 
 private lateinit var adapter: MsgAdapter
 override fun onCreate(savedInstanceState: Bundle?) {
	 ...
	 adapter = MsgAdapter(msgList)
	 ...
 }
 override fun onClick(v: View?) {
	 ...
	 //adapter?.notifyItemInserted(msgList.size - 1)
	 adapter.notifyItemInserted(msgList.size - 1)
	 ...
 }
}

```

当你对一个全局变量使用了lateinit关键字时，请一定要确保它在被任何地方调用之前
已经完成了初始化工作，否则Kotlin将无法保证程序的安全性。
还可以通过代码来判断一个全局变量是否已经完成了初始化，这样在某些时候能够
有效地避免重复对某一个变量进行初始化操作。

```
if (!::adapter.isInitialized) {
 adapter = MsgAdapter(msgList)
}
...
```
`::adapter.isInitialized`可用于判断adapter变量是否已经初始化。
虽然语法看上去有点奇怪，但这是固定的写法。然后我们再对结果进行取反。

### 4.5.1  密封类优化代码
密封类通常可以结合RecyclerView适配器中的ViewHolder一起使用，密封类的使用场景远不止于此，它可以在很多时候
帮助你写出更加规范和安全的代码，所以非常值得一学。

新建一个Kotlin文件，文件名就叫`Result.kt`：
```
interface Result
class Success(val msg: String) : Result
class Failure(val error: Exception) : Result
```
定义了一个Result接口，用于表示某个操作的执行结果，接口中不用编写任何内容。
然后定义了两个类去实现Result接口：
一个Success类用于表示成功时的结果，一个Failure类用于表示失败时的结果，
这样就把准备工作做好了，接下来再定义一个getResultMsg()方法，用于获取最终执行结果的信息：
```
fun getResultMsg(result: Result) = when (result) {
 is Success -> result.msg
 is Failure -> result.error.message
 else -> throw IllegalArgumentException()
}
```

通过when语句来判断：
如果Result属于Success，那么就返回成功的消息；
如果Result属于Failure，那么就返回错误信息。
到目前为止，代码都是没有问题的，但比较让人讨厌的是，
接下来我们**不得不编写一个else条件**，
否则Kotlin编译器会认为这里缺少条件分支，
代码将无法编译通过。但实际上Result的执行结果只可能是Success或者Failure，
这个else条件是永远走不到的，所以我们在这里直接抛出了一个异常，
只是**为了满足Kotlin编译器的语法检查**而已。

如果我们现在新增了一个Unknown类并实现Result接口，用于表示未知的执行结果，
但是忘记在getResultMsg()方法中添加相应的条件分支，
编译器在这种情况下是不会提醒我们的，
而是会在运行的时候进入else条件里面，
从而抛出异常并导致程序崩溃。

**Kotlin的密封类可以很好地解决这个问题**，
密封类的关键字是`sealed class`，它的用法同样非常简单，我们可以轻松地将Result接口改
造成密封类的写法：
```
sealed class Result
class Success(val msg: String) : Result()
class Failure(val error: Exception) : Result()
```
只是将interface关键字改成了sealed class。另外，由于密封类是一个可继承的类，因此在继承它的时候需要在后面加上一对括号
```
fun getResultMsg(result: Result) = when (result) {
 is Success -> result.msg
 is Failure -> "Error is ${result.error.message}"
}
```
 
为什么这里去掉了else条件仍然能编译通过呢？
这是因为**当在when语句中传入一个密封类变量作为条件时，Kotlin编译器会自动检查该密封类有哪些子类，并强制要求你将每一个子类所对应的条件全部处理。** 
这样就可以保证，即使没有编写else条件，也不可能会出现漏写条件分支的情况。
而如果我们现在新增一个Unknown类，并也让它继承自Result，
此时getResultMsg()方法就一定会报错，必须增加一个Unknown的条件分支才能让代码编译通过。
密封类及其所有子类只能定义在**同一个文件的顶层位置**，不能嵌套在其他类中，这是被密封类底层的实现机制所限制的

```
sealed class MsgViewHolder(view: View) : RecyclerView.ViewHolder(view)

class LeftViewHolder(view: View) : MsgViewHolder(view) {
 val leftMsg: TextView = view.findViewById(R.id.leftMsg)
}

class RightViewHolder(view: View) : MsgViewHolder(view) {
 val rightMsg: TextView = view.findViewById(R.id.rightMsg)
}


class MsgAdapter(val msgList: List<Msg>) : RecyclerView.Adapter<MsgViewHolder>() {
 ...
 override fun onBindViewHolder(holder: MsgViewHolder, position: Int) {
	 val msg = msgList[position]
	 when (holder) {
		 is LeftViewHolder -> holder.leftMsg.text = msg.content
		 is RightViewHolder -> holder.rightMsg.text = msg.content
	 }
 }
 ...
}


```

将`RecyclerView.Adapter`的泛型指定成刚刚定义的密封类MsgViewHolder，
这样onBindViewHolder()方法传入的参数就变成了MsgViewHolder。
然后我们只要在when语句当中处理LeftViewHolder和RightViewHolder这两种情况就可以了，
那个讨厌的else终于不再需要了，这种RecyclerView适配器的写法更加规范也更加推荐。

# 5. 扩展函数
不修改某个类的源码，仍可以打开这个类，增加新功能；

统计字符串中的字母、数字及特殊字符的数据：
```
//个单例类中定义了一个lettersCount()函数
objce StringUtil{
	func lettersCount(data:String):Inter{
		var count=0;
		for(c in data){
			if(c.isLetter()){
				count++
			}
		}
		return count;
	}
}

//java 最标准的用法
val str = "ABC123xyz!@#"
val count = StringUtil.lettersCount(str)
```

我们可以使用一种更加面向对象的思维来实现这个功能，
说将lettersCount()函数添加到String类当中
```
//语法
fun ClassName.methodName(param1: Int, param2: Int): Int {
 return 0
}
```

相比于定义一个普通的函数，定义扩展函数只需要在**函数名的前面加上一个ClassName.的语法结构**，
就表示将该函数添加到指定类当中了

由于我们希望向String类中添加一个扩展函数，因此需要先创建一个`String.kt`文件。
**文件名虽然并没有固定的要求**，但是我建议向哪个类中添加扩展函数，
就定义一个同名的Kotlin文件，这样便于你以后查找。当然，
**扩展函数也是可以定义在任何一个现有类当中**的，
并不一定非要创建新文件。不过通常来说，最好将它定义成顶层方法，这样可以让扩展函数拥有全局的访问域。
```
fun String.lettersCount(): Int {
 var count = 0
 for (char in this) {
	 if (char.isLetter()) {
		count++
	 }
 }
 return count
}

```

## 5.1 有趣的运算符重载
运算符重载使用的是`operator`关键字，只要在指定函数的前面加上operator关键字，
就可以实现运算符重载的功能了。 

**不同的运算符对应的重载函数**也是不同的。比如说加号运算符对应的是`plus()`函数，
减号运算符对应的是`minus()`函数。
```
class Obj {
 operator fun plus(obj: Obj): Obj {
	// 处理相加的逻辑
 }
}
```

关键字**operator**和函数名**plus**都是固定不变的，
而接收的参数和函数返回值可以根据你的逻辑自行设定。
那么上述代码就表示一个Obj对象可以与另一个Obj对象相加，最终返回一个新的Obj对象。对应的调用方式如下：
```
val obj1 = Obj()
val obj2 = Obj()
val obj3 = obj1 + obj

//这种obj1 + obj2的语法看上去好像很神奇，
//但其实这就是Kotlin给我们提供的一种语法糖，
//它会在编译的时候被转换成obj1.plus(obj2)的调用方式。

```

表 可重载的运算符

|语法糖表达式|实际调用函数|
|--|--|
|a + b |a.plus(b)|
|a - b |a.minus(b)|
|a * b |a.times(b)|
|a / b |a.div(b)|
|a % b |a.rem(b)|
|a++   |a.inc()|
|a--   |a.dec()|
|+a    |a.unaryPlus()|
|-a    |	a.unaryMinus()|
|!a    |a.not()|
|a == b|a.equals(b)|
|a > b |a.equals(b)|
|a < b |a.equals(b)|
|a >= b|a.equals(b)|
|a <= b|a.compareTo(b)|
|a..b  |a.rangeTo(b)|
|a[b]  |a.get(b)|
|a[b] = c| a.set(b, c)|
|a in b |b.contains(a)|

## 5.3 重载与扩展 
函数的核心思想就是将传入的字符串重复n次
```
fun getRandomLengthString(str: String): String {
 val n = (1..20).random()
 val builder = StringBuilder()
 repeat(n) {
	builder.append(str)
 }
 return builder.toString()
}
``` 
使用运算符重载，能够使用`str * n`这种写法来表示让str字符串重复n次
```
operator fun String.times(n: Int): String {
 val builder = StringBuilder()
 repeat(n) {
	builder.append(this)
 }
 return builder.toString()
}
```

**解释：**
首先，operator关键字肯定是必不可少的；
然后既然是要重载乘号运算符，参考表 可知，函数名必须是`times`；
最后，由于是定义扩展函数，因此还要在方向名前面加上`String.`的语法结构。
在times()函数中，我们借助StringBuilder和repeat函数将字符串重复n次，最终将结果返回。


现在，字符串就拥有了和一个数字相乘的能力，比如执行如下代码：
```
val str = "abc" * 3
println(str)
```

其实Kotlin的String类中已经提供了一个用于**将字符串重复n遍的`repeat()`函数**，
因此times()函数还可以进一步精简成如下形式:
```
operator fun String.times(n: Int) = repeat(n)
```
掌握上面的规则：在getRandomLengthString()函数中使用这种魔术一般的写法了
`fun getRandomLengthString(str: String) = str * (1..20).random()`

# 6 高级用法
## 6.1 高阶函数定义
如果一个函数接收另一个函数作为参数，或者返回值的类型是另一个函数，
那么该函数就称为高阶函数。

函数类型不同于定义一个普通的字段类型，函数类型的语法规则是有点特殊的，
基本规则如下：
```
(String, Int) -> Unit
```
`->左边`的部分就是用来声明该函数**接收什么参数**的，
多个参数之间使用逗号隔开，如果不接收任何参数，写一对空括号就可以了。

`->右边`的部分用于声明该函数的返回值是什么类型，
如果没有返回值就使用Unit，它大致相当于Java中的void。

```
fun example(func: (String, Int) -> Unit) {
 func("hello", 123)
}

fun num1AndNum2(num1: Int, num2: Int, operation: (Int, Int) -> Int): Int {
 val result = operation(num1, num2)
 return result
}


fun plus(num1: Int, num2: Int): Int {
 return num1 + num2
}
fun minus(num1: Int, num2: Int): Int {
 return num1 - num2
}


val result1 = num1AndNum2(num1, num2, ::plus)

```

`::plus`和`::minus`这种写法是一种**函数引用方式**，
表示将plus()和minus()函数作为参数传递给num1AndNum2()函数

使用这种函数引用的写法虽然能够正常工作，但是如果每次调用任何高阶函数的时候都还得先
定义一个与其函数类型参数相匹配的函数，这是不是有些太复杂了
Kotlin还支持其他多种方式来调用高阶函数，比如Lambda表达式、匿名函数、成员引用等
```
val result1 = num1AndNum2(num1, num2) { n1, n2 ->
 n1 + n2
}

val result2 = num1AndNum2(num1, num2) { n1, n2 ->
 n1 - n2 //最后一行代码会自动作为返回值
}
```

扩展函数：
给StringBuilder类定义了一个build扩展函数
```
fun StringBuilder.build(block: StringBuilder.() -> Unit): StringBuilder {
 block()
 return this
}

``` 
函数类型的前面加上了一个`StringBuilder.`的语法结构,这才是**定义高阶函数完整的语法规则**，
在函数类型的前面加上`ClassName.`就表示这个函数类型是定义在哪个类中的

调用build函数时传入的Lambda表达式将会**自动拥有StringBuilder的上下文**(同时这也是apply函数的实现方式)


## 6.2 内联函数

```
fun num1AndNum2(num1: Int, num2: Int, operation: (Int, Int) -> Int): Int {
 val result = operation(num1, num2)
 return result
}

fun main() {
 val num1 = 100
 val num2 = 80
 val result = num1AndNum2(num1, num2) { n1, n2 -> n1 + n2 }
}
```

java 代码
```
public static int num1AndNum2(int num1, int num2, Function operation) {
 int result = (int) operation.invoke(num1, num2);
 return result;
}
public static void main() {
 int num1 = 100;
 int num2 = 80;
 int result = num1AndNum2(num1, num2, new Function() {
	 @Override
	 public Integer invoke(Integer n1, Integer n2) {
		return n1 + n2;
	 }
 });
}
```

并不是严格对应了Kotlin转换成的Java代码。可以看到，
在这里num1AndNum2()函数的第三个参数变成了一个Function接口，
这是一种Kotlin内置的接口，里面有一个待实现的invoke()函数。
而num1AndNum2()函数其实就是调用了Function接口的invoke()函数，
并把num1和num2参数传了进去。

在调用num1AndNum2()函数的时候，之前的Lambda表达式在这里变成了Function接口的匿名类实现，
然后在invoke()函数中实现了n1 + n2的逻辑，并将结果返回。
这就是Kotlin高阶函数背后的实现原理。

原来我们一直使用的**Lambda表达式在底层被转换成了匿名类的实现方式**。
这就表明，我们每调用一次Lambda表达式，都会创建一个新的匿名类实例，
当然也会**造成额外的内存和性能开销。**

为了解决这个问题，Kotlin提供了内联函数的功能，它可以将使用Lambda表达式带来的运行时
开销完全消除。

只需要在定义高阶函数时加上inline关键字的声明即可

```
inline fun num1AndNum2(num1: Int, num2: Int, operation: (Int, Int) -> Int): Int {
 val result = operation(num1, num2)
 return result
}

```
Kotlin编译器会将**内联函数中的代码在编译的时候自动替换到调用它的地方**，
这样也就不存在运行时的开销了
首先Kotlin编译器会将Lambda表达式中的代码替换到函数类型参数调用的地方

![内联函数](/static/开发/andriod/imgs/inlineFun_01.png)

接下来，再将内联函数中的全部代码替换到函数调用的地方

![内联函数](/static/开发/andriod/imgs/inlineFun_02.png)

最终的代码就被替换成了:

![内联函数](/static/开发/andriod/imgs/inlineFun_03.png)


### 6.2.1 内联其中的一个Lambda表达式

使用<font color="green">`noinline`</font>关键字了

```
inline fun inlineTest(block1: () -> Unit, noinline block2: () -> Unit) {

}
```

使用inline关键字声明了inlineTest()函数，原本block1和block2这两个函数类型参数所引用的Lambda表达式都会被内联。
但是我们在block2参数的前面又加上了一个noinline关键字，
那么现在就只会对block1参数所引用的Lambda表达式进行内联了

noinline 作用：
因为内联的函数类型参数在编译的时候会被进行代码替换，因此它没有真正的参数属性。
非内联的函数类型参数可以自由地传递给其他任何函数，因为它就是一个真实的参数，
而内联的函数类型参数只允许传递给另外一个内联函数，这也是它最大的局限性。

内联函数所引用的Lambda表达式中是可以使用return关键字来进行函数返回的，
而非内联函数只能进行局部返回
```
fun printString(str: String, block: (String) -> Unit) {
 println("printString begin")
 block(str)
 println("printString end")
}
fun main() {
 println("main start")
 val str = ""
 printString(str) { s ->
	 println("lambda start")
	 if (s.isEmpty()) return@printString
	 println(s)
	 println("lambda end")
 }
 println("main end")
}

//运行结果：
lambda start
printString begin
lambda start
printString end
main end

```
- 定义了一个叫作`printString()`的高阶函数，用于在Lambda表达式中打印传入的字符串参数
- <font color="blue"> Lambda表达式中是不允许直接使用`return`关键字的</font>，
这里使用了<font color="green">`return@printString`</font>的写法，表示进行局部返回，并且不再执行Lambda表达式的剩余部分代码。


如果声明为内联函数：
```
inline fun printString ....
....

//运行结果：
lambda start
printString begin
lambda start
```

## 6.3 crossinline

绝大多数高阶函数是可以直接声明成内联函数的，但是极少情况例外：
```
inline fun runRunnable(block: () -> Unit) {
 val runnable = Runnable {
	block()
 }
 runnable.run()
}

```

**没有加上inline关键字**声明的时候绝对是可以正常工作的，
但是在加上inline关键字之后就会提示：
"Cant't inline 'block'there:it may contain no-local returns.Add 'crossinline'modifier to parameter declaration 'block'"

首先，在runRunnable()函数中，我们创建了一个Runnable对象，并在Runnable的Lambda表达式中调用了传入的函数类型参数。而
Lambda表达式在编译的时候会被转换成匿名类的实现方式，也就是说，上述代码实际上是在
**匿名类中调用了传入的函数类型参数。**

- <font color="blue"> **内联函数**所引用的Lambda表达式**允许使用return关键字**进行函数返回</font>，但是由于我们是在
匿名类中调用的函数类型参数，此时是不可能进行外层调用函数返回的，最多只能对匿名类中
的函数调用进行返回，因此这里就提示了上述错误。

- 高阶函数中创建了**另外的Lambda或者匿名类的实现**，并且在这些实现
中**调用函数类型参数**，此时再将高阶函数声明成内联函数，就一定会提示错误。

借助crossinline关键字就可以很好地解决这个问题
```
inline fun runRunnable(crossinline block: () -> Unit) {
 val runnable = Runnable {
	block()
 }
 runnable.run()
}
```

上面分析可知：
**内联函数的Lambda表达式中允许使用return关键字，和高阶函数的匿名类实现中不允许使用return关键字之间造成了冲突**

<font color="green">`crossinline`关键字就像一个契约:保证在内联函数的Lambda表达式中一定不会使用return关键字</font>

声明了crossinline之后，我们就无法在调用runRunnable函数时的Lambda表达式中使用return关键字进行函数返回了，
但是仍然可以使用return@runRunnable的写法进行局部返回。


## 6.4 高级函数应用
```
val editor = getSharedPreferences("data", Context.MODE_PRIVATE).edit()
editor.putString("name", "Tom")
editor.putInt("age", 28)
editor.putBoolean("married", false)
editor.apply()

```

```
//Google的KTX库中已经自带了一个edit函数
fun SharedPreferences.open(block: SharedPreferences.Editor.() -> Unit) {
 val editor = edit()
 editor.block()
 editor.apply()
}

```


# 6.5 Java与Kotlin代码之间的转换
将Java代码转换成Kotlin代码，在语法层面上是有一定规律

只需要复制这段代码，然后在AndroidStudio中打开任意一个Kotlin文件，在这里进行粘贴。
进行一键代码转换，但是它只会按照固定的
语法变化规律来执行转换工作，而不会自动应用Kotlin的各种优秀特性。因此，依靠这种自动转
换工具只能实现基础版的Kotlin语法，细节方面的代码优化还是得靠我们手动完成

可以直接将一个Java文件以及其中的所有代码一次性转换成Kotlin版本。具体操作方法是，首先在Android Studio中打
开该Java文件，然后点击导航栏中的Code→Convert Java File to Kotlin File

Kotlin代码又该如何转换成Java代码？
Kotlin拥有许多Java中并不存在的特性，
我们却可以先将Kotlin代码转换成Kotlin字节码，
然后再通过反编译的方式将它还原成Java代码。

这种反编译出来的代码可能无法像正常编写的Java代码那样直接运行

# 7 泛型和委托
泛型有静态行为（编译阶段），运行时行为；
## 7.1 基础泛型（与java相当）
Java早在1.5版本中就引入了泛型的机制，泛型主要有两种定义方式：
一种是定义泛型类，
另一种是定义泛型方法
```
class MyClass<T> {
 fun method(param: T): T {
	return param
 }
}

```
上面的MyClass就是一个泛型类，MyClass中的方法允许使用T类型的参数和返回值;
不想定义一个泛型类，只是想定义一个泛型方法
```
class MyClass {
 fun <T> method(param: T): T {
	return param
 }
 //泛型上界
 fun <T : Number> method(param: T): T {
	return param
 } 
}
```

在默认情况下，所有的泛型都是可以指定成可空类型的，这是因为在不手动指定上界的
时候，<font color="blue">泛型的上界默认是Any?</font>。而如果想要让泛型的类型不可为空，只需要将泛型的上界手动
指定成Any就可以了。

高级函数中：
```
fun StringBuilder.build(block: StringBuilder.() -> Unit): StringBuilder {
 block()
 return this
}
```
可以通过where 关键字实现对泛型参数增加多个约束条件：
```
//长在地上的水果
fun <T> cut(t:T) where T:Fruit,T:Ground{}

cut(Watermelon(3.0)) //允许
cut(Apple(20))  //不允许
```


只是build函数只能作用在StringBuilder类上面,通过泛型知识学习，对build函数进行扩展，
让它实现和apply函数完全一样的功能
```
fun <T> T.build(block: T.() -> Unit): T {
 block()
 return this
}

```

## 7.2 类委托和委托属性
委托是一种设计模式，它的基本理念是：操作对象自己不会去处理某段逻辑，而是会把工作委托给另外一个辅助对象去处理。

Java对于委托并没有语言层级的实现，而像C#等语言就对委托进行了原生的支持；
Kotlin中也是支持委托功能的，并且将委托功能分为了两种：**类委托**和**委托属性**

### 7.2.1 类委托
**核心思想在于将一个类的具体实现委托给另一个类去完成**
```
class MySet<T>(val helperSet: HashSet<T>) : Set<T> {
 override val size: Int
 get() = helperSet.size
 override fun contains(element: T) = helperSet.contains(element)
 override fun containsAll(elements: Collection<T>) = helperSet.containsAll(elements)
 override fun isEmpty() = helperSet.isEmpty()
 override fun iterator() = helperSet.iterator()
}

```
既然都是调用辅助对象(`helperSet`)的方法实现，那还不如直接使用辅助
对象得了。这么说确实没错，但如果我们只是<font color="red">让大部分的方法实现调用辅助对象中的方法，少部分的方法实现由自己来重写</font>，
甚至加入一些自己独有的方法，那么MySet就会成为一个全新的数据结构类，这就是委托模式的意义所在。

待实现方法比较少还好，要是有几十甚至上百个方法的话，
每个都去这样调用辅助对象中的相应方法实现，
那可真是要写哭了。
在Kotlin中可以通过类委托的功能来解决：
Kotlin中委托使用的关键字是<font color="green">`by`</font>,只需要在接口声明的后面使用by关键字，再接上受委托
的辅助对象，就可以免去之前所写的一大堆模板式的代码了：
<font color="green">
```
class MySet<T>(val helperSet: HashSet<T>) : Set<T> by helperSet {
}
```
</font>

如果我们要对某个方法进行**重新实现**，
只需要单独重写那一个方法就可以了，其他的方法仍然可以享受类委托所带来的便利
```
class MySet<T>(val helperSet: HashSet<T>) : Set<T> by helperSet {
 fun helloWorld() = println("Hello World")
 override fun isEmpty() = false
}

```

新增了一个helloWorld()方法，并且重写了isEmpty()方法。

### 7.2.1 类属性 
类委托的核心思想是将一个类的具体实现委托给另一个类去完成，
而委托属性的核心思想是**将一个属性（字段）的具体实现委托给另一个类去完成**。
 

```
class MyClass {
 var p by Delegate()
}


class Delegate {
 var propValue: Any? = null
 
 //myClass:委托功能可以在什么类中使用
 //KProperty<*>：Kotlin中的一个属性操作类  可用于获取各种属性相关的值,
 //<*>这种泛型的写法表示你不知道或者不关心泛型的具体类型
 operator fun getValue(myClass: MyClass, prop: KProperty<*>): Any? {
	return propValue
 }
 operator fun setValue(myClass: MyClass, prop: KProperty<*>, value: Any?) {
	propValue = value
 }
}
```
使用by关键字连接了左边的p属性和右边的Delegate实例,代表着将p属性的具体实现委托给了Delegate类去完成

**当调用p属性的时候会自动调用Delegate类的getValue()方法，当给p属性赋值的时候会自动调用Delegate类的setValue()方法**
这是一种标准的代码实现模板，在Delegate类中我们必须实现`getValue()`和`setValue()`这两个方法，并且都要使用**operator**关键字进行声明

## 7.3 自己的lazy函数
学习了Kotlin的委托功能之后，我们就可以对by lazy的工作原理进行解密了，它的基本语法结构如下
```
val p by lazy { ... }

```
`by`是Kotlin中的关键字，lazy在这里只是一个高阶函数而已。在lazy函数中会创建并返回一个Delegate对象，
当我们调用p属性的时候，其实调用的是Delegate对象的getValue()方法，
然后getValue()方法中又会调用lazy函数传入的Lambda表达式，这样表达式中的代码就可以得到执行了，
并且调用p属性后得到的值就是Lambda表达式中最后一行代码的返回值。

```
class Later<T>(val block: () -> T) {
 //value变量对值进行缓存
 var value: Any? = null
 
 //Any? 希望Later的委托功能在所有类中都可以使用
 operator fun getValue(any: Any?, prop: KProperty<*>): T { 
	 //如果value为空就调用构造函数中传入的函数类型参数去获取值
	 if (value == null) {
		value = block()
	 }
	 return value as T
 }
}

```

由于懒加载技术是不会对属性进行赋值的，因此这里我们就不用实现setValue()方法了。

为了让它的用法更加类似于lazy函数，最好再定义一个顶层函数。这个函数直接写在`Later.kt`文件中就可以
`fun <T> later(block: () -> T) = Later(block)`,这个顶层函数的作用很简单：
创建Later类的实例，并将接收的函数类型参数传给Later类的构造函数

测试：
```
val p by later {
 Log.d("TAG", "run codes inside later block")
 "test later"
}

```
当Activity启动的时候，later函数中的那行日志是不会打印的。
只有当你首次点击按钮的时候，日志才会打印出来，说明代码块中的代码成功执行了。
而当你再次点击按钮的时候，日志也不会再打印出来，因为代码块中的代码只会执行一次。

# 8. infix函数构建更可读的语法
`A to B`这样的语法结构构建键值对，包括Kotlin自带的`mapOf()`函数，
以及我们在自己创建的`cvOf()`函数,这种语法结构的优点是可读性高，相比于调用一个函数，它更接近于使用英语的语法来编写程序;

**to**并不是Kotlin语言中的一个关键字，之所以我们能够使用`A to B`这样的语法结构，
是因为Kotlin提供了一种高级语法糖特性：`infix函数`,**把编程语言函数调用的语法规则调整了一下**
比如`A to B`这样的写法，实际上等价于`A.to(B)`的写法;

String类中有一个startsWith()函数:
```
if ("Hello Kotlin".startsWith("Hello")) {
 // 处理具体的逻辑
}
```

借助infix函数，我们可以使用一种更具可读性的语法来表达这段代码。
新建一个infix.kt文件：
```
infix fun String.beginsWith(prefix: String) = startsWith(prefix)
```
除去最前面的infix关键字，这是一个String类的**扩展函数**。我们给String类添,加了一个beginsWith()函数，它也是用于判断一个字符串是否是以某个指定参数开头的，并
且它的内部实现就是调用的String类的startsWith()函数。

加上了**infix关键字**之后，`beginsWith()`函数就变成了一个**infix函数**，
这样除了传统的函数调用方式之外，
我们还可以用一种**特殊的语法糖格式**调用beginsWith()函数:
```
if ("Hello Kotlin" beginsWith "Hello") {
 // 处理具体的逻辑
}
```


**infix函数允许我们将函数调用时的小数点、括号等计算机相关的语法去掉，从而使用一种更
接近英语的语法来编写程序，让代码看起来更加具有可读性。**

语法糖格式的特殊性有两个**比较严格的限制**:
- infix函数是不能定义成顶层函数的，它**必须是某个类的成员函数**，可以使用扩展函数的方式将它定义到某
个类当中;
- infix函数**必须接收且只能接收一个参数**，至于参数类型是没有限制的

```
val list = listOf("Apple", "Banana", "Orange", "Pear", "Grape")
if (list.contains("Banana")) {
 // 处理具体的逻辑
}

//===>
infix fun <T> Collection<T>.has(element: T) = contains(element)

if (list has "Banana") {
 // 处理具体的逻辑
}

```

`A to B ` 的源码：
```
public infix fun <A, B> A.to(that: B): Pair<A, B> = Pair(this, that)
```

使用定义泛型函数的方式将to()函数定义到了A类型下，并且接收一个B类型的参数。
因此A和B可以是两种不同类型的泛型，也就使得我们可以构建出字符串to整型这样的键值对。
再来看to()函数的具体实现，非常简单，就是创建并返回了一个Pair对象。
也就是说，A to B这样的语法结构实际上得到的是一个包含A、B数据的Pair对象，
而mapOf()函数实际上接收的正是一个Pair类型的可变参数列表，这样我们就将这种神奇的语法结构完全解密了。


# 9. 泛型
## 9.1 泛型实例化
在JDK 1.5之前，Java是没有泛型功能的，那个时候诸如List之类的数据结构可以存储任意类型
的数据，取出数据的时候也需要`手动向下转型`才行，这不仅麻烦，而且很危险。

DK 1.5中，Java终于引入了泛型功能。这不仅让诸如List之类的数据结构变得简单好
用，也让我们的代码变得更加安全。

Java的泛型功能是通过**类型擦除机制**来实现的,说**泛型对于类型的约束**只在**编译时期存在**。
运行的时候仍然会按照JDK 1.5之前的机制来运行，JVM是识别不出来我们在代码中指定的泛型类型的。
例如，假设我们创建了一个List<String>集合，虽然在编译时期只能向集合中添加字符串类型的元素，
但是在运行时期JVM并不能知道它本来只打算包含哪种类型的元素，只能识别出来它是个List。

所有基于JVM的语言，它们的泛型功能都是通过类型擦除机制来实现的，其中当然也包括了Kotlin。
这种机制使得我们不可能使用`a is T`或者`T::class.java`这样的语法，
因为T的实际类型在运行的时候已经被擦除了。

**内联函数**中的代码会在编译的时候**自动被替换到调用它的地方**，
这样的话也就不存在什么泛型擦除的问题了，
因为代码在编译之后会直接使用实际的类型来替代内联函数中的泛型声明。

![内联函数泛型](/static/开发/andriod/imgs/内联函数泛型.png)


`bar()`是一个带有泛型类型的内联函数，`foo()`函数调用了`bar()`函数，在代码编
译之后，bar()函数中的代码将可以获得泛型的实际类型。

这就意味着，**Kotlin中是可以将内联函数中的`泛型进行实化`的**

- 首先，该函数必须是**内联函数**才行，也就是要用<font color="green">`inline`</font>关键字来修饰该函数。
- 其次，在声明泛型的地方必须加上<font color="green">`reified`</font>关键字来表示该泛型要进行实化。

```
inline fun <reified T> getGenericType() {
}
```
上述函数中的泛型T就是一个被实化的泛型,从函数名就可以看出来了，这里
我们准备实现一个获取泛型实际类型的功能:
```
inline fun <reified T> getGenericType() = T::class.java
```
函数直接返回了当前指定泛型的实际类型:
-  `getGenericType()`函数直接返回了当前指定泛型的实际类型。
- T.class这样的语法在Java中是不合法的
- 在Kotlin中，借助泛型实化功能就可以使用`T::class.java`这样的语法了
```
 val result1 = getGenericType<String>()
 val result2 = getGenericType<Int>()
 println("result1 is $result1")
 println("result2 is $result2")

```


## 9.2 泛型实化的应用
泛型实化功能允许我们在泛型函数当中**获得泛型的实际类型**，这也就使得类似于`a is T`、`T::class.java`这样的语法成为了可能。
灵活运用这一特性将可以实现一些不可思议的语法结构。
```
val intent = Intent(context, TestActivity::class.java)
context.startActivity(intent) 
```

写法也是可以忍受的，Kotlin的泛型实化功能使得我们拥有了更好的选择
```
inline fun <reified T> startActivity(context: Context) {
 val intent = Intent(context, T::class.java)
 context.startActivity(intent)
}

```
定义了一个`startActivity()函数`，该函数接收一个Context参数，并同时使用**inline和reified**关键字让泛型T成为了一个被实化的泛型，

Intent接收的第二个参数本来应该是一个具体Activity的Class类型，但由于现在T已经是一个
被实化的泛型了，因此这里我们可以直接传入T::class.java。最后调用Context的
startActivity()方法来完成Activity的启动。


```
startActivity<TestActivity>(context)
```

泛型实化和高阶函数使这种语法结构成为了可能
传入参数的写法：
```
inline fun <reified T> startActivity(context: Context, block: Intent.() -> Unit) {
 val intent = Intent(context, T::class.java)
 intent.block()
 context.startActivity(intent)
}

```
调用：
```
startActivity<TestActivity>(context) {
 putExtra("param1", "data")
 putExtra("param2", 123)
}
```

## 9.3 泛型的协变
Kotlin的内置API中使用了很多协变和逆变的特性,

约定: 一个泛型类或者泛型接口中的方法它的参数列表是接收数据的地方，
因此可以称它为in位置（? super T），而它的返回值是输出数据的地方，因此可以称它为out位置（T extends Object）.

![约定](/static/开发/andriod/imgs/协变逆变.png)

```
open class Person(val name: String, val age: Int)
class Student(name: String, age: Int) : Person(name, age)
class Teacher(name: String, age: Int) : Person(name, age)
```

定义了一个Person类，类中包含name和age这两个字段,然后又定义了Student和Teacher这两个类，让它们成为Person类的子类。
如果某个方法接收一个Person类型的参数，而我们传入一个Student的实例，这样合不合法呢？很显然，因为Student是Person的子类，学生也是人呀，
因此这是一定合法的。

如果某个方法接收一个`List<Person>`类型的参数，而我们传入一个`List<Student>`的实例，这样合不合法呢？看上去好像也挺正确的，但是Java中是不
允许这么做的，因为`List<Student>`不能成为`List<Person>`的子类，否则将可能存在类型转换的安全隐患。
```
class SimpleData<T> {
 private var data: T? = null
 fun set(t: T?) {
	data = t
 }
 fun get(): T? {
	return data
 }
}
```

如果编程语言允许向某个接收SimpleData<Person>参数的方法传入
SimpleData<Student>的实例,那么如下代码就会是合法的:
```
fun main() {
 val student = Student("Tom", 19)
 val data = SimpleData<Student>()
 data.set(student)
 handleSimpleData(data) // 实际上这行代码会报错，这里假设它能编译通过
 val studentData = data.get()
}
fun handleSimpleData(data: SimpleData<Person>) {
 val teacher = Teacher("Jack", 35)
 data.set(teacher)
}

```
创建了一个Student的实例，并将它封装到SimpleData<Student>当中，
然后将SimpleData<Student>作为参数传递给handleSimpleData()方法。
但是handleSimpleData()方法接收的是一个SimpleData<Person>参数（这里假设可以编译通过），那么在handleSimpleData()方法
中，我们就可以创建一个Teacher的实例，
并用它来替换SimpleData<Person>参数中的原有数据。
这种操作肯定是合法的，因为Teacher也是Person的子类，所以可以很安全地将Teacher的实例设置进去。

我们调用SimpleData<Student>的get()方法
来获取它内部封装的Student数据，可现在SimpleData<Student>中实际包含的却是一个Teacher的实例，
那么此时必然会产生类型转换异常,

为了杜绝这种安全隐患，Java是不允许使用这种方式来传递参数的。换句话说，即使
Student是Person的子类,SimpleData<Student>并不是SimpleData<Person>的子
类。

主要原因是我们在handleSimpleData()方
法中向SimpleData<Person>里设置了一个Teacher的实例。如果SimpleData在泛型T上是
只读的话，肯定就没有类型转换的安全隐患了，那么这个时候SimpleData<Student>可不可
以成为SimpleData<Person>的子类呢

<font color="yellowRed">

**泛型协变**：假如定义了一个MyClass<T>的泛型类，其中A是B的子类型，
同时`MyClass<A>`又是`MyClass<B>`的子类型，
那么我们就可以称MyClass在T这个泛型上是协变的。

让`MyClass<A>`成为`MyClass<B>`的子类型:

如果一个泛型类在其泛型类型的数据上是**只读**的话，
那么它是没有类型转换安全隐患的。
而要实现这一点，则需要让MyClass<T>类中的所有方法都不能接收T类型的参数。
换句话说，**T只能出现在out位置上，而不能出现在in位置上**。

</font>

```
class SimpleData<out T>(val data: T?) {
 fun get(): T? {
	return data
 }
}
```

对SimpleData类进行了改造，在泛型T的声明前面加上了一个out关键字。
这就意味着现在T只能出现在out位置上，而不能出现在in位置上，
同时也意味着SimpleData在泛型T上是协变的。

由于这里我们使用了val关键字，所以构造函数中的泛型T仍然是只读的，
因此这样写是合法且安全的。
另外，即使我们使用了var关键字，但只要给它加上private修饰符，
保证这个泛型T对于外部而言是不可修改的，那么就都是合法的写法。
```
fun main() {
 val student = Student("Tom", 19)
 val data = SimpleData<Student>(student)
 handleMyData(data)
 val studentData = data.get()
}
fun handleMyData(data: SimpleData<Person>) {
 val personData = data.get()
}
```
由于SimpleData类已经进行了**协变声明**，那么`SimpleData<Student>`自然就是
`SimpleData<Person>`的子类了，所以这里可以安全地向handleMyData()方法中传递参
数。

虽然这里泛型声明的是Person类型，实际获得的会是一个Student的实例，但由于Person是Student的父类，向上
转型是完全安全的，所以这段代码没有任何问题。

如果某个方法接收一个List<Person>类型的参数，而传入的却是一个
List<Student>的实例， 在Java中是不允许这么做的。注意这里我的用语，在Java中是不允
许这么做的。

因为Kotlin已经默认给许多内置的API加上了协变声明，
其中就包括了各种集合的类与接口。Kotlin中的List本身就是只读的，
(如果你想要给List添加数据，需要使用MutableList才行)

既然List是只读的，也就意味着它天然就是可以协变的,List在泛型E的前面加上了out关键字，说明List在泛型E上是协变的,不过这里还有一点需要说
明，原则上在声明了协变之后，泛型E就只能出现在out位置上;

可是你会发现，在contains()方法中，泛型E仍然出现在了in位置上。
这么写本身是不合法的，因为在in位置上出现了泛型E就意味着会有类型转换的安全隐患。
但是contains()方法的目的非常明确，它只是为了判断当前集合中是否包含参数中传入的这个元素，
而并不会修改当前集合中的内容，因此这种操作实质上又是安全的。
为了让编译器能够理解我们的这种操作是安全的，
这里在泛型E的前面又加上了一个<font color="green">`@UnsafeVariance` </font>注解，
这样编译器就会允许泛型E出现在in位置上了.

## 9.4.泛型的逆变
逆变与协变却完全相反，假如定义了一个MyClass<T>的泛型类，
其中A是B的子类型，同时`MyClass<B>`又是`MyClass<A>`的子类型，
那么我们就可以称MyClass在T这个泛型上是逆变的。协变和逆变的区别：

![协变逆变](/static/开发/andriod/imgs/协变逆变_1.png)

逆变的规则好像挺奇怪的，**原本A是B的子类型，怎么`MyClass<B>`能反过来成为`MyClass<A>`的子类型**

先定义一接口用于执行一些转换操作：
```
interface Transformer<T> {
 fun transform(t: T): String
}

fun main() {
 val trans = object : Transformer<Person> {
	 override fun transform(t: Person): String {
	   return "${t.name} ${t.age}"
	 }
 }
 handleTransformer(trans) // 这行代码会报错
}

fun handleTransformer(trans: Transformer<Student>) {
 val student = Student("Tom", 19)
 val result = trans.transform(student)
}
```

`handleTransformer()`方法接收的是一个`Transformer<Student>`类型的参数，这里在
handleTransformer()方法中创建了一个Student对象，并调用参数的transform()方法将Student对象转换成一个字符串。

从安全的角度来分析是没有任何问题的，因为Student是Person的子类，使用Transformer<Person>的匿名类实现将Student对象转换成一个字符串也是绝对安全的，
并不存在类型转换的安全隐患。但是实际上，在调用handleTransformer()方法的时候却会提示语法错误，
原因也很简单， <font color="red">`Transformer<Person>`并不是`Transformer<Student>`的子类型。</font>

逆变就可以派上用场了，它就是专门用于处理这种情况的。修改Transformer接口中的代码:
```
interface Transformer<in T> {
 fun transform(t: T): String
}

```
泛型T的声明前面加上了一个in关键字。这就意味着现在T只能出现在in位置上，而不能出现在out位置上，同时也意味着Transformer在泛型T上是逆变的，
刚才的代码就可以编译通过且正常运行了，因为此时`Transformer<Person>`已经成为了`Transformer<Student>`的子类型。
先**假设**逆变是允许让泛型T出现在out位置上的，然后看一看可能会产生什么样的安全隐患:
```
interface Transformer<in T> {
 fun transform(name: String, age: Int): @UnsafeVariance T
}
fun main() {
 val trans = object : Transformer<Person> {
	 override fun transform(name: String, age: Int): Person {
		return Teacher(name, age)
	 }
 }
 handleTransformer(trans)
}
fun handleTransformer(trans: Transformer<Student>) {
 val result = trans.transform("Tom", 19)
}
```
- Transformer<Person>的匿名类实现中，我们使用transform()方法中传入的name和age
参数构建了一个Teacher对象，并把这个对象直接返回。由于transform()方法的返回值要求
是一个Person对象，而Teacher是Person的子类，因此这种写法肯定是合法的。
- 在handleTransformer()方法当中，我们调用了Transformer<Student>的
transform()方法，并传入了name和age这两个参数，期望得到的是一个Student对象的返回，
然而实际上transform()方法返回的却是一个Teacher对象，因此这里必然会造成类型转换异常

总结: Kotlin在提供协变和逆变功能时，就已经把各种潜在的类型转换安全隐患全部考虑进
去了。只要我们严格按照其语法规则，让**泛型在协变时只出现在out位置上**，**逆变时只出现在in位置上**，就不会存在类型转换异常的情况。
虽然@UnsafeVariance注解可以打破这一语法规则，但同时也会带来额外的风险，所以你在使用@UnsafeVariance注解时，必须很清楚自己在干什么才行。

API 中 Comparable是一个用于比较两个对象大小的接口:
```
interface Comparable<in T> {
 operator fun compareTo(other: T): Int
}
```

如果我们使用Comparable<Person>实现了让两个Person对象比较大小的逻辑，那么用这段逻辑去比较两
个Student对象的大小也一定是成立的，因此让Comparable<Person>成为Comparable<Student>的子类合情合理，这也是逆变非常典型的应用。

# 10. 协程
协程和线程有点类似，可以简单理解一种轻量级线程，线程是非常重量级的，
它需要操作系统的调度才能实现不同线程之间的切换，
协程却可以仅在语言的层面就能实现不同协程之间的切换，从而提升并发编程的运行效率；

比如定义:
```
fun foo() {
 a()
 b()
 c()
}
fun bar() {
 x()
 y()
 z()
}

```

没有开启线程的情况下，先后调用foo()和bar()两个方法，理论上结果一定是：
`a(),b(),c() ` 和 `x(),y(),z()`才能够执行，如果使用**协程**，协程A中调用foo(),协程B中调用 bar()方法，
虽然他们仍然会执行在同一个线程当中，但是在执行foo()方法时**随时都有可能**被挂起转而去执行bar()方法，
执行 bar() 方法也随时都有可能被挂起转而执行foo(),最终的输出**结果不确定**。

**协程运行我们在单线程模式下模拟多线程编程得效果，代码执行时得挂起与恢复完全是有编程语言控制得和操作系统无关**

Kotlin 并没有把协程纳入标准库API中，而是以依赖库得形式提供：
```
...
implement "org.jetbrains.kotlinx:kotlinx-coroutines-core:1.1.1"
implement "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.1.1"  //android 中才能用到
```

## 10.1 使用方式
### 10.1.1 Global.launch
`Global.launch` 函数可以创建一个协程得作用域，代码块（LAmbda表达式）就是在协程中运行；

```
fun main(){
	Global.Scope.lauch{
		pringln("code run is coroutine scope")
	}
}

```

上面得日志没有打印出来，因为 `Global.launch` 每次创建得都是一个**顶层协程**，这种协程当应用程序结束也会跟着一起结束；
`Thread.sleep(1000)`

`delay()`函数可以让当前协程延迟指定时间后再运行，但它和Thread.sleep()方法不同。
<font color="green">delay()</font>函数是一个非阻塞式的挂起函数，它只会挂起当前协程，并不会影响其他协程的运行。

我们让协程挂起1.5秒，但是主线程却只阻塞了1秒,这样协程未执行完，主程序就结束了；

### 10.1.2 runBlocking 函数
runBlocking函数同样会创建一个<font color="yellowRed">协程的作用域</font>，但是它可以**保证在协程作用域内的所有代码
和子协程没有全部执行完之前一直阻塞当前线程**。需要注意的是，
runBlocking函数通常只应该在**测试环境下使用**，在正式环境中使用容易产生一些性能上的问题。
```
fun main() {
 runBlocking {
	 println("codes run in coroutine scope")
	 delay(1500)
	 println("codes run in coroutine scope finished")
 }
}
 
```

```
fun main() {

	runBlocking {
	 launch {
		 println("launch1")
		 delay(1000)
		 println("launch1 finished")
	 }
	 launch {
		 println("launch2")
		 delay(1000)
		 println("launch2 finished")
	 }
	 }
 }
```

这里的<font color="green">launch</font>函数和我们刚才所使用的GlobalScope.launch函数不同。
首先它必须在协程的作用域中才能调用，
其次它会在当前协程的作用域下创建**子协程**。
子协程的特点是如果外层作用域的协程结束了，
该作用域下的所有子协程也会一同结束。
相比而言，GlobalScope.launch函数创建的永远是顶层协程，这一点和线程比较像，
因为线程也没有层级这一说，永远都是顶层的。


```
fun main() {
 val start = System.currentTimeMillis()
 runBlocking {
	 repeat(100000) {
		 launch {
			println(".")
		 }
	 }
 }
 val end = System.currentTimeMillis()
 println(end - start)
}

```

随着launch函数得复杂 ，可能需要将部分代码提取到一个单独得函数中，这个时候产生一个问题：
**在launch函数中编写得代码是拥有协程作用域得，但是提取到一个单独得函数中就没有协程作用域**
为此Kotlin提供一个 `suspend`关键字，使用它可以将任意函数申明成<font color="yellowRed">挂起函数</font>，而挂起函数之间都可以互相调用得：
```
suspend fun printDot(){
	pringln(".")
	delay(1000)
}
```
这样就可以在 printDot()函数中调用 delay()函数；

suspend关键字只能将一个函数声明成挂起函数，是无法给它提供协程作用域的，比如现在尝试在 printDot()函数中调用launch函数，一定无法调用成功，
因为**launch函数要求必须在协程作用域当中调用**。

上述问题可以记住 <font color="yellowRed">coroutineScope</font>函数来解决，
也是一个挂起函数，因此可以在任何其他挂起函数中调用，其
特点是会**继承外部的协程的作用域并创建一个子协程**，
借助这个特性，可以给任何挂起函数提供协程作用域：
```
//在挂起函数中调用 launch函数
suspend fun printDot()= coroutineScope{
	launch{
		println(".")
		delay(1000)
	}
}
```

`coroutineScope`函数和`runBlocking`函数有点类似，
它可以保证其作用域内的所有代码和子协程在全部执行完之前，外部的协程会一致被挂起:
```
fun mian(){
	runBlocking{
	    //挂起函数 且提供协程作用域
		//里面带面执行完后才继续外面的协程代码
		roroutineScope{
			launch{
				for( i in 1..10){
					pringln(i)
					delay(1000)
				}
			}
		}
		pringln("coroutineScope finished")
	}
	pringln("runBlocking finished")
}
```
先使用runBlocking函数创建了一个**协程作用域**，然后调用coroutineScope函数创建
了一个**子协程**。在coroutineScope的作用域中，
我们又调用**launch函数创建了一个子协程**，并通过for循环依次打印数字1到10，每次打印间隔一秒钟。


**由此可见，coroutineScope函数确实是将外部协程挂起了，只有当它作用域内的所有代码和
子协程都执行完毕之后，coroutineScope函数之后的代码才能得到运行。**

<font color="yellowRed">

coroutineScope函数和runBlocking函数的作用是有点类似的，
但是**coroutineScope函数只会阻塞当前协程**，既不影响其他协程，也不影响任何线程，
因此是不会造成任何性能上的问题的。
而**runBlocking函数由于会挂起外部线程**，如果你恰好又在主线程中当中调用它的话，那么就有可能会导致界面卡死的情况

</font>

GlobalScope.launch、runBlocking、launch、coroutineScope这几种作用域构建器，
它们都可以用于创建一个新的协程作用域。
不过GlobalScope.launch和runBlocking函数是可以在任意地方调用的，
coroutineScope函数可以在协程作用域或挂起函数中调用，
而launch函数只能在协程作用域中调用。

runBlocking由于会阻塞线程，因此只建议在测试环境下使用。
而GlobalScope.launch由于每次创建的都是顶层协程，一般也不太建议使用，除非你非常明确就是要创建顶层协程。
不太建议使用顶层协程主要还是因为它**管理起来成本太高**了。
举个例子，比如我们在某个Activity中使用协程发起了一条网络请求，由于网络请求是耗时的，
用户在服务器还没来得及响应的情况下就关闭了当前Activity，
此时按理说应该取消这条网络请求，或者至少不应该进行回调，
因为Activity已经不存在了，回调了也没有意义。

不管是GlobalScope.launch函数还是launch函数，它们都会返回一个Job对象，
只需要调用Job对象的cancel()方法就可以取消协程了

```
val job = GlobalScope.launch {
 // 处理具体的逻辑
}
job.cancel()

```


**下实际项目中比较常用的写法:**
```
val job = Job()
val scope = CoroutineScope(job)
scope.launch {
	// 处理具体的逻辑
}
job.cancel()

```
CoroutineScope()是函数，不是类；
调用launch函数可以创建一个新的协程，
但是launch函数只能用于执行一段逻辑，却不能获取执行的结果，因为它的返回值永远是一个Job对象。

`async函数`必须在协程作用域当中才能调用，
它会创建一个新的子协程并返回一个`Deferred对象`，
如果我们想要获取async函数代码块的执行结果，只需要调用`Deferred对象的await()`方法即可。
```
fun main() {
 runBlocking {
	 val result = async {
		5 + 5
	 }.await()
	 
	 println(result)
 }
}
```

在调用了`async函数`之后，代码块中的代码就会**立刻开始执行**。
当调用await()方法时，如果代码块中的代码还没执行完，
那么await()方法会将当前**协程阻塞**住，直到可以获得async函数的执行结果。

```
fun main() {
 runBlocking {
	 val start = System.currentTimeMillis()
	 val result1 = async {
		 delay(1000)
		 5 + 5
	 }.await()
	 val result2 = async {
		 delay(1000)
		 4 + 6
	 }.await()
 
	 println("result is ${result1 + result2}.")
	 val end = System.currentTimeMillis()
	 println("cost ${end - start} ms.") 
 }
}

```
整段代码的运行耗时是2032毫秒，说明这里的两个async函数确实是一种串行的关系，
前一个执行完了后一个才能执行;种写法明显是非常低效的，
因为两个async函数完全可以同时执行从而提高运行效率。
现在对上述代码使用如下的写法进行修改:
```
fun main() {
 runBlocking {
 val start = System.currentTimeMillis()
 val deferred1 = async {
	 delay(1000)
	 5 + 5
 }
 val deferred2 = async {
	 delay(1000)
	 4 + 6
 }
 println("result is ${deferred1.await() + deferred2.await()}.")
 val end = System.currentTimeMillis()
 println("cost ${end - start} milliseconds.")
 }
}

```
仅在需要用到async函数的执行结果时才调用await()方法进行获取，
这样两个async函数就变成一种并行关系,
在整段代码的运行耗时变成了1029毫秒，运行效率的提升显而易见

## 10.2 较特殊的作用域构建器
`withContext()`函数是一个挂起函数，大体可以将它理解成**async函数的一种简化版写法**；
```
fun main() {
 runBlocking {
	 val result = withContext(Dispatchers.Default) {
		5 + 5
	 }
	 println(result)
 }
}
```
## 10.2.1 线程参数
调用withContext()函数之后，<font color="yellowRed"> 会立即执行代码块中的代码，同时将外部协程挂起。</font>
当代码块中的代码全部执行完之后，会将最后一行的执行结果作为withContext()函数的返回值返回，
因此基本上相当于`val result = async{ 5 + 5}.await()`的写法。
唯一不同的是，withContext()函数强制要求我们指定一个<font color="greenRed"> 线程参数</font>

协程是一种轻量级的线程的概念，因此很多传统编程情况下需要开启多线程执行的并发任务，
现在只需要在一个线程下开启多个协程来执行就可以了。
但是这并不意味着我们就永远不需要开启线程了，
比如说**Android中要求网络请求必须在子线程中进行**，即使你开启了协程去执行网络请求，
假如它是主线程当中的协程，那么程序仍然会出错。这个时候我们就应该**通过线程参数给协程指定一个具体的运行线程**。

线程参数主要有以下3种值可选：
- Dispatchers.Default
	默认低并发的线程策略，当你要执行的代码属于计算密集型任务时，开启过高的并发反而可能会影响任务的运行效率，
	此时就可以使用Dispatchers.Default
- Dispatchers.IO
	使用一种较高并发的线程策略，当你要执行的代码大多数时间是在阻塞和等待中，
	比如说执行网络请求时，为了能够支持更高的并发数量，此时就可以使用Dispatchers.IO
- Dispatchers.Main
	不会开启子线程，而是在Android主线程中执行代码，
	但是这个值只能在Android项目中使用，
	纯Kotlin程序使用这种类型的线程参数会出现错误。

协程作用域构建器中，除了coroutineScope函数之外，其他所有的函数都是可以指定这样一个线程参数的，
只不过withContext()函数是强制要求指定的，而其他函数则是可选的。

## 10.3  协程简化回调
回调机制基本上是依靠匿名类来实现的，但是匿名类的写法通常比较烦琐，
比如如下代码:
```
HttpUtil.sendHttpRequest(address, object : HttpCallbackListener {
 override fun onFinish(response: String) {
	// 得到服务器返回的具体内容
 }
 override fun onError(e: Exception) {
	// 在这里对异常情况进行处理
 }
})
```

借助<font color="green">suspendCoroutine</font>函数就能将传统回调机制的写法大幅简化,
suspendCoroutine函数必须在**协程作用域**或**挂起函数**中才能调用，
它接收一个Lambda表达式参数，主要作用是将当前协程立即挂起，
然后在一个普通的线程中执行Lambda表达式中的代码。
Lambda表达式的参数列表上会传入一个Continuation参数，
调用它的`resume()`方法或`resumeWithException()`可以让协程恢复执行。

回调写法进行优化
```
suspend fun request(address: String): String {
 return suspendCoroutine { continuation ->
	 HttpUtil.sendHttpRequest(address, object : HttpCallbackListener {
		 override fun onFinish(response: String) {
			continuation.resume(response)
		 }
		 override fun onError(e: Exception) {
			continuation.resumeWithException(e)
		 }
	 })
 }
}
```

request()函数是一个挂起函数，并且接收一个address参数。
在request()函数的内部，调用了刚刚介绍的suspendCoroutine函数，这样当前协程就会被立刻挂起，
而Lambda表达式中的代码则会在普通线程中执行。
接着我们在Lambda表达式中调用HttpUtil.sendHttpRequest()方法发起网络请求，
并通过传统回调的方式监听请求结果。
如果请求成功就调用Continuation的resume()方法恢复被挂起的协程，并传入服务器响应
的数据，该值会成为`suspendCoroutine`函数的返回值。
如果请求失败，就调用Continuation的`resumeWithException()`恢复被挂起的协程，并传入具体的异常原因。
```
suspend fun getBaiduResponse() {
 try {
	 val response = request("https://www.baidu.com/")
	 // 对服务器响应的数据进行处理
 } catch (e: Exception) {
	// 对异常情况进行处理
 }
}
 

```

由于 getBaiduResponse()是一个挂起函数，
因此当它调用了request()函数时，当前的协程就会被立刻挂起，然后一直等待网络请求成功
或失败后，当前协程才能恢复运行。这样即使不使用回调的写法，我们也能够获得异步网络请
求的响应数据，而如果请求失败，则会直接进入catch语句当中。

getBaiduResponse()函数被声明成了挂起函数
因为suspendCoroutine函数本身就是要结合协程一起使用的。不过通过合理的项目架构设计，
我们可以轻松地将各种协程的代码应用到一个普通的项目:

```
suspend fun <T> Call<T>.await(): T {
	 return suspendCoroutine { continuation ->
		 enqueue(object : Callback<T> {
		 override fun onResponse(call: Call<T>, response: Response<T>) {
			 val body = response.body()
			 if (body != null) continuation.resume(body)
			 else continuation.resumeWithException(
			 RuntimeException("response body is null"))
		 }
		 override fun onFailure(call: Call<T>, t: Throwable) {
			continuation.resumeWithException(t)
		 }
		 })
	}
}
```

await()函数仍然是一个挂起函数，然后我们给它声明了一个泛型T，并将await()函数定义成了Call<T>的扩展函数，这样
所有返回值是Call类型的Retrofit网络请求接口就都可以直接调用await()函数了

await()函数中使用了suspendCoroutine函数来挂起当前协程，并且由于扩展函数的
原因，我们现在拥有了Call对象的上下文，那么这里就可以直接调用enqueue()方法让
Retrofit发起网络请求。接下来，使用同样的方式对Retrofit响应的数据或者网络请求失败的情
况进行处理就可以了。另外还有一点需要注意，在onResponse()回调当中，我们调用body()
方法解析出来的对象是可能为空的。如果为空的话，这里的做法是手动抛出一个异常，你也可
以根据自己的逻辑进行更加合适的处理。
有了await()函数之后，我们调用所有Retrofit的Service接口都会变得极其简单，比如刚才
同样的功能就可以使用如下写法进行实现：

```
suspend fun getAppData() {
 try {
	 val appList = ServiceCreator.create<AppService>().getAppData().await()
	 // 对服务器响应的数据进行处理
 } catch (e: Exception) {
	// 对异常情况进行处理
 }
}
```

# 11. 编写好用的工具
## 11.1 最大值
```
fun max(vararg nums: Int): Int {
 var maxNum = Int.MIN_VALUE
 for (num in nums) {
	maxNum = kotlin.math.max(maxNum, num)
 }
 return maxNum
}

```
`vararg`关键字，它允许方法接收任意多个同等类型的参数

```
fun <T : Comparable<T>> max(vararg nums: T): T {
 if (nums.isEmpty()) throw RuntimeException("Params can not be empty.")
 var maxNum = nums[0]
 for (num in nums) {
	 if (num > maxNum) {
		maxNum = num
	 }
 }
 return maxNum
}
```


## 11.2 简化Toast的用法
```
fun String.showToast(context: Context) {
 Toast.makeText(context, this, Toast.LENGTH_SHORT).show()
}
fun Int.showToast(context: Context) {
 Toast.makeText(context, this, Toast.LENGTH_SHORT).show()
}

//加时长
fun String.showToast(context: Context, duration: Int = Toast.LENGTH_SHORT) {
 Toast.makeText(context, this, duration).show()
}
```

```
"This is Toast".showToast(context, Toast.LENGTH_LONG)
```

## 11.3 简化Snackbar
```
Snackbar.make(view, "This is Snackbar", Snackbar.LENGTH_SHORT)
 .setAction("Action") {
 // 处理具体的逻辑
 }
 .show()
```
简化：
```
fun View.showSnackbar(text: String, duration: Int = Snackbar.LENGTH_SHORT) {
 Snackbar.make(this, text, duration).show()
}
fun View.showSnackbar(resId: Int, duration: Int = Snackbar.LENGTH_SHORT) {
 Snackbar.make(this, resId, duration).show()
}

```
```
//调用
view.showSnackbar("This is Snackbar")
```

增加参数参数（高级函数）
```
fun View.showSnackbar(text: String, actionText: String? = null,
 duration: Int = Snackbar.LENGTH_SHORT, block: (() -> Unit)? = null) { 
	 val snackbar = Snackbar.make(this, text, duration)
	 if (actionText != null && block != null) {
		 snackbar.setAction(actionText) {
			block()
		 }
	 }
	 snackbar.show()
}
fun View.showSnackbar(resId: Int, actionResId: Int? = null,
 duration: Int = Snackbar.LENGTH_SHORT, block: (() -> Unit)? = null) {
 
 val snackbar = Snackbar.make(this, resId, duration)
 if (actionResId != null && block != null) {
	 snackbar.setAction(actionResId) {
		block() 
	 }
 }
 snackbar.show()
}

```

# 12 DSL构建专有的语法结构

领域特定语言（Domain Specific Language），
它是编程语言赋予开发者的一种特殊能力，
通过它我们可以编写出一些看似脱离其原始语法结构的代码，
从而构建出一种专有的语法结构。
用infix函数构建出的特有语法结构就属于DSL

目标是通过高阶函数的方式来实现DSL，这也是Kotlin中实现DSL最常见的方式

Gradle是一种基于Groovy语言的构建工具，
因此上述的语法结构其实就是Groovy提供的DSL功能。
借助Kotlin的DSL，我们也可以实现类似的语法结构：
```
class Dependency {
 val libraries = ArrayList<String>()
 fun implementation(lib: String) {
	libraries.add(lib)
 }
}
```

使用了一个List集合来保存所有的依赖库，然后又提供了一个implementation()方
法，用于向List集合中添加依赖库

再定义一个dependencies高阶函数
```
fun dependencies(block: Dependency.() -> Unit): List<String> {
 val dependency = Dependency()
 dependency.block()
 return dependency.libraries
}

```

dependencies函数接收一个函数类型参数，并且该参数是定义到Dependency类中的，
因此调用它的时候需要先创建一个Dependency的实例，然后再通过该实例调用函数类型参数;
```
dependencies {
 implementation("com.squareup.retrofit2:retrofit:2.6.1")
 implementation("com.squareup.retrofit2:converter-gson:2.6.1")
}

```

由于dependencies函数接收一个函数类型参数，
因此这里我们可以传入一个Lambda表达式。
而此时的Lambda表达式中拥有Dependency类的上下文，
因此当然就可以直接调用Dependency类中的implementation()方法来添加依赖库了

## 12.1 三行三列表格


```
	<table>
		 <tr>
			 <td>Apple</td>
			 <td>Grape</td>
			 <td>Orange</td>
		 </tr>
		 <tr>
			 <td>Pear</td>
			 <td>Banana</td>
			 <td>Watermelon</td>
		 </tr>
	</table>
```
	
1. 定义 td
	```
	class Td {
	 var content = ""
	 fun html() = "\n\t\t<td>$content</td>"
	}
	```
2. 定义tr
	```
	class Tr {
	 private val children = ArrayList<Td>()
	 fun td(block: Td.() -> String) {
		 val td = Td()
		 td.content = td.block()
		 children.add(td)
	 }
	 fun html(): String {
		 val builder = StringBuilder()
		 builder.append("\n\t<tr>")
		 for (childTag in children) {
			builder.append(childTag.html())
		}
		 builder.append("\n\t</tr>")
		 return builder.toString()
	 }
	}
	```

3. 定义table
	```
	class Table {
	 private val children = ArrayList<Tr>()
	 fun tr(block: Tr.() -> Unit) {
		 val tr = Tr()
		 tr.block()
		 children.add(tr)
	 }
	 fun html(): String {
		 val builder = StringBuilder()
		 builder.append("<table>")
		 for (childTag in children) {
			builder.append(childTag.html())
		 }
		 builder.append("\n</table>")
		 return builder.toString()
	 }
	}
	```
4. 使用
	```
	val table = Table()
	table.tr {
	 td { "Apple" }
	 td { "Grape" }
	 td { "Orange" }
	}
	table.tr {
	 td { "Pear" }
	 td { "Banana" }
	 td { "Watermelon" }
	}
	```

5. 对table 进行简化
定义一个table()函数,
接收一个定义到Table类中的函数类型参数，当调用table()函数时，会
先创建一个Table对象，接着调用函数类型参数，这样Lambda表达式中的代码就能得到执
行。最后调用Table的html()方法获取生成的HTML代码，并作为最终的返回值返回。
	```
	fun table(block: Table.() -> Unit): String {
	 val table = Table()
	 table.block()
	 return table.html()
	}

	```

6. 使用(语义性很强，一看就懂)
	```
	fun main() {
	 val html = table {
		 tr {
			 td { "Apple" }
			 td { "Grape" }
			 td { "Orange" }
		 }
		 tr {
			 td { "Pear" }
			 td { "Banana" }
			 td { "Watermelon" }
		 }
	 }
	 println(html)
	}

	```
	
# 13. 开发者问题
## 13.1 多继承
Brid类同时实现了Flyer和Animal两个接口，但它都拥有默认的Kind方法，会引起所说的砖石问题，
Kotlin提供了对应的方式来解决这个问题
- super 关键字
我们可以使用它来指定继承那个父类的方法，当然也可以主动实现方法，覆盖父类接口的方法；
```
suuper<Flyer>.kind()

//override
override fun kind()="a flying ${this.namge}"
```

- 内部类解决多继承问题方案
将一个类定义在另一个类的内部，成为内部类，
内部类可以继承一个余外部类无关的类，这保证了内部类的独立性，可以尝试用这个特性解决多继承问题；

在Kotlin 中声明一个内部类，必须在前面加一个inner关键字。
在java 中，我们通过在内部类的语法上增加一个static关键字，把它变成一个嵌套类，
而Kotlin则是相反的思路，默认是一个嵌套类，必须加上inner关键字才是一个内部类，
也就是说可以把静态类的内部看成嵌套类；

内部类包含着对其外部类实例的引用，在内部类我们可以使用外部类中的属性，
而嵌套类不包含对其外部类使用的引用；
```
class Mule{
	fun funFast(){
		HorseC().runFast()
	}
	fun doLongTimeThing(){
		DonkeyC().doLongTimeThing()
	}
	private inner class HorseC:Horse()
	private inner class DonkeyC:Donkey()
}
```
在一个类的内部定义多个内部类，每个内部类的实例都有自己的独立状态，它们余外部对象的信息相互独立；

- 委托
```
val laziness:String by lazy{
	"I am a lazy-initialized string"
}
```

委托除了延迟属性这种内置行为外，还提供了一种可以观察属性的行为，
与我们所说的观察者模式很类似，

```
interface CanFly{
	fun fly()
}

interface CanEat{
	fun eat()
}

open class Flyer :CanFly{
	override fun fly(){
		println("I can fly")
	}
}

open class Animal:CanEat{
	override fun eat(){
		println("I can eat")
	}
}

class Bird(flyer:Flyer,animal:Animal):CanFly by flyer,CanEat by animal{}

fun main(arg:Array<String>){
	val flyer=Flyer()
	val animal=Animal()
	val b=Bird(flyer,animal)
	b.fly()
	b.eat()
}
```

a. 接口是无状态的，接口中实现的默认方法也是简单的，不能实现复杂的逻辑，也不推荐在接口中实现复杂的方法逻辑
利用上面委托这种实现，虽然也是接口委托，但它是用一个具体的列去实现实现方法的逻辑，可以拥有更强大的能力；
b. 假设我们用继承的类是A，委托对象是B、C，我们在具体调用的时候并不是向组合一样A.B.method, 而是可以直接调用A.method,
这更能表达A拥有该method的能力;

## 13.2 数据类
kotlin 中引入data class 语法，来解决java中的代码繁琐问题，
数据类，该概念并非Kotlin首创，比如Scale中的 case class 也是同样的概念；
```
data class Bird(var weight:Double,var age:Int,var color:String)

```
data 关键字 的后面 Kotlin 编译器帮助我们做了很多事情：反编译后的Java代码：
```
public final class Bird{
	private double weight;
	private int age;
	@NotNull
	private String color；
	
	public final double getWeight(){
		return this.weight;
	}
	public final void setWeight(double var1){
		this.weight=var1;
	}
	public final int getAge(){
		return this.age;
	}
	
	@NotNull
	public final String getColor(){
		return this.color;
	}
	public final void setColor(@NotNull String var1){
		Intrinsics.checkParameterIsNotNull(var1,"<set-?>");
		this.color=var1;
	}
	public final double component1(){ //java 中没有
		return this.weight;
	}
	.....
	public final double component3(){ //java 中没有
		 
	}
	@NotNull
	public final Bird copy(....){
		Intrinsics.checkParameterIsNotNull(color,"color");
		return new Bird(weight,age,color)
	}
	public final Bird copy$default(Bird v0,double v1,....){
		if((v1&1)!=0){
			v1=vo.weight;
		}
		return v0.copy(v1,v2,v3)
	}
}
```

copy 方法从已有的数据来对象拷贝一个新的数据类对象；也可以传入相应参数来形成不同的对象；

componentN 可以理解为类属性的值，N代表属性的顺序，

将属性绑定到类上，
将类的属性绑定到相应变量:
```
val b1=Bird(20.0,1,"blue")
//通用方式
val weight=b1.weight
val age=b1.age
val color=b1.color

//kotlin 进阶
val (weight,age,color)=b1

String bridInfo="20.0,1,bule"
val (weight,age,color)=birdInfo.split(",")
```

通过编译器的约定实现`解构`，Kotlin对数据的解构有一定的限制，在数组中它默认最多允许赋值5个变量；
因为若是变量过多，效果适得其反；到后期你都搞不清楚那个值要赋给哪个变量；

除了利用编译器帮助生成componentN方法外，可以自己实现对应属性的componentN 方法；
```
data class Bird(w,a,c){
	var sex=1
	operator fun component4():Int{ //operator
		return this.set
	}
	
	constructor(weight:Double,a,c,sex):this(weight,a,c,sex){
		this.sex=sex
	}
	
}


val (weight,age,color,sex)=b1
```

除了数组支持解构外，可提供其他常用的数据来，让使用者不必主动声明这些数据类，他们分别是Pair和Triple,
Pair 是二元组，Triple是三元组, 它们都是数据来，属性可以是任意类型，我们可以按照属性的顺序来获取对应属性的值；
```
public data class Pair<out A,out B>(public val first:A,public val second:B)
public data class Triple<out A,out B,out C>(public val first:A,public val second:B,val third:C)

//解构
val (weight,age)=Pair(20.0,1)
```

**数据类中的解构是基于componentN函数**，如果自己不声明componentN函数，会默认根据主构造函数参数来生成具体个数的componentN函数，与从狗仔函数中的参数无关；

声明数据类条件
- 必须拥有一个构造方法，且至少包含一个参数（一个没有数据的数据类是没有任何用处的）
- 数据类构造方法的参数强制使用var或者val进行什么；
- data class 之前不能使用abstract、open、sealed或者inner进行修饰；

作为数据解构被广泛运用到业务中，它像一个普通类一样，可以把不同类型的值封装在一处。
我们把数据类和when 表达式结合在一起，就可以提供更强大的业务组织和表达能力；

数据类的另一个典型应用：代替我们在java中的建造者模式；

## 13.2 从static 到object
在java 中，static 是非常重要的特性，用来修饰类、方法或属性，static修饰的内容都是属于类的，
但是定义时却与普通的变量和方法混杂在一起，显得格格不入；

在Kotlin 中将告别static这样的语法，它引用了全新的关键字 `object`，可以完全替代使用static的所有场景。
当然还有其他功能比如 ：单例对象及简化匿名表达式等。

### 13.2.1 天生单例
在java我们必须通过设置构造方法私有化，以及提供静态方法创建实例的方法来创建单例对象；
在Kotlin 中，由于object的存在，我们可以直接使用它来实现单例；

由于object全局声明的对象只有一个，所有它并不用语法上的初始化，甚至都不需要构造方法；
单例也可以和普通类一样实现接口和继承类，可以将它看成一个不需要我们主动初始化的类，它也可以拥有扩展方法，

单例对象会在系统加载的使用初始化，全局只有一个，object的另一个作用：代替java中的匿名内部类（方法内掺杂类申明看起来复杂，不易阅读理解）；
object表达式可以赋值给一个变量，这在我们重复使用的时候将会减少很多代码。

用于代替匿名内部类的object表达式在运行中不像我们在单例模式中那样全局只有一个对象，而是每次运行时都会生成一个新的对象；

对象表达式和Lambda表达式 --代替--匿名内部类：
当匿名内部类使用的类接口只需要实现一个方法时：使用Lambda表达式更适合；
匿名内部类有多个方法实现的时候，使用object表达式更适合；

## 13.3 伴生类
Java 中类方法和属性，对象方法和属性都结构上混合在一起，Kotlin 中引入了伴生对象`companion object`的概念；
伴生对象跟java中static修饰效果性质一样，全局只有一个单例，需要声明在类的内部，在类被装载时会被初始化；

伴生对象的另一个作用是可以实现工厂方法模式，
我们可以使用从构造方法实现工厂方法模式这种方法有一下缺点：
- 利用多个构造方法语义不明确，只能靠参数区分；
- 每次获取对象时都需要重新构造对象；
