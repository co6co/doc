---
layout: post
title: JAVA疯狂讲义
subtitle:
date:       2021-06-30 09:49:17
categories: [JAVA]
tags: [JAVA,JAVA疯狂讲义]
---


# 基本数据类型
	char	-->
				int-->long-->float-->double
byte-->short-->
小类型可自动转换为大的数据类型
大类型转小类型需要强制转换 可能出现数据丢失

掐套循环合适使用 `break label` 来结束外层循环
```
outerlable: 						 //定义外层循环便签
for(int i=0;i<10;i++){
	for(int j =0;j<10;j++){
		if(j==5){
			break outerlable; 		//跳出便签所标识的循环
			//continue outerlable;  //继续便签所标识的循环
		}
	}
} 
```


# 数组
引用变量只是一个引用，这个引用变量可以指向任何有效的内存，只有当该引用指向有效内存后，才能通过该变量访问数组元素，实际数组元素存储在内存堆中。  
当执行 `int[] arr=new int[5];` 系统负责向堆上分配空间，并分配默认的初始值。
可以将多维数组 理解为一维数组。
````java
int[] arr;				//推荐使用
int arr[];				//语义不好理解
````


# 类与对象
如果堆内的对象没有任何变量指向该对象，程序将无法访问该对象，这个对象将变成垃圾，将被垃圾回收机制回收，释放该对象所占的内存区

java 的方法不能单独存在，它必须属于一个类或者对象
类方法可以使用`类`来调用，也可使用类`对象`来调用,
> 注意 这个与'C#'有区别，C# 不支持对象调用类方法

类不能定义相同的成员变量 ，即使一个是类成员一个是对象成员。
允许局部变量和成员变量同名。


当使用对象来调用类方法是和类直接调用时一样的效果，实际上，依然是委托给该类来访问类成员，因此即使某个实例为null 它也是可以访问它所属的类成员。

## 形参可变的参数 
`String ... strs` 只能是参数的最后一个

## 递归反复
包含一个隐式循环，但这种重复执行无需循环控制

## 重载
返回值不能重载 因 用户在调用方法是可以忽略返回值，这样JAVA Runtime 将不知道调用的方法

单一参数与可变参数重载，如果参数只有一个参数，那调用的是单一参数方法，
如果想调用可变参数方法是可使用 `(new Type[]{arg})` 传参

将局部变量换为成员变量的危害：
1. 增大 变量的生存时间，导致更大的系统开销
2. 扩大了变量的作用域，不利于提高程序的内聚性。

## 类加载
类在使用前需要经过 加载 类验证 、类准备、类解析、类初始化等几个阶段

## 访问控制符
修饰类、属性和方法
```
private < default < protected < public
```
default : 可以被`相同包`中的类访问
protected: 可以被`相同包`中的类访问,也可以被`不同包`中的`子类`访问
## 构造器
在构造器中可以使用 `this(arg)`调用其他构造器,使用`super(arg)`调用父类的构造器
##继承
Java 子类不能获得父类的构造器
子类是一个特殊的父类，额外增加新的属性和方法

1. 重写（override） 发生在子类和父类的同名方法直接
遵循‘两同两小一大’
	- 两同：方法名、形参相同，
	- 两小：返回值应比父类小或相等，异常更小或相等
	- 一大：访问权限应大或相等。
	

使用父类方法 `super`
2. 重载（overload）同一个类的多个同名方法之间

## 多态
向上转型（upcasting），由系统自动完成，
通过引用变量来访问其宝航的实例属性，系统总是试图访问它`编译时`类所定义的属性，而不是它`运行时`类所定义的属性
使用强制类型转换 时需要用 `instanceof` 来判断是否能转换,从而避免出现 ClassCastException

## 初始化代码块
与构造函数非常相似，先于构造函数执行，
是 java 类的第四类成员，1.属性，2.方法，3.构造器
可定义多个初始化代码块，同类型的代码块 间，先定义的先执行。
分为：`静态初始化代码块`（static修饰），和`对象初始化代码块`，
因没有名字、标识，无法通过类、对象来调用初始化代码块，只能在java 对象创建时隐式调用；

普通代码块、声明属性、指定属性默认值 都是初始化代码 执行顺序与原代码位置相同。

java 在创建一个对象时，先为该对象的所有属性`分配空间`，`对属性执行初始化（1.初始化模块或者声明属性是指定的默认值，2.构造函数）`
初始化代码块，对所有对象执行一样操作无参。
对于继承，系统先 `上溯`到Object 的初始化代码块、构造器 ，。。。。，最后 该类的 初始化代码块、构造器

## final 
可修饰 变量（不允许重新赋值）、方法（子类不允许覆盖）、类（不允许派生）
final 修饰的变量 要么在`成员变量`指定初始值，要么在`初始化代码块`中赋值，要么在`构造器`中赋值；`不能重复`指定
修饰的`局部变量`声明是如果不赋值，则可以在`后面的代码`中`赋值一次`
不能重新赋值，但可以改变引用变量指向的值
```
final int[] arr={0,2,3};
Arrays.sort(arr);
arr[0]=1;
```


## 内部类
1. 静态内部类
 - 已被称为 `类内部类`
 - 静态内部类不能访问外部类实例成员
 - 可以访问外部类的类成员
 
 - 接口内部类：接口定义的内部类 默认使用 `public static ` 修饰 即 接口的内部类属于静态内部类
2. 非静态内部类
 - `不允许`在`非静态内部类`中定义`静态成员`,即 不能有 `静态方法，静态属性、静态初始化块`
 - 编译时生成的文件名`外部类名称.class``外部类名称$内部类名称.class`
 
 - 外部类.this.成员名  //访问外部成员
 - this.成员名		   //访问内部类成员
  
 - 分静态内部类的子类不一定是内部类，可以是一个 `顶层类`；子内必须保留外部类的引用，即有内部类子类的实例，就必须要 外部类的实例
	```
	public class test extends Out.In{
		public test(Out out){
			out.super("hello");// 通过传入的Out对象显示调用In的构造器
		}
	}
	``` 
 
 ## 局部内部类
 在方法中定义的类
 - 不能在外部类（方法所属类）以外的地方使用
 - 不能使用访问控制符和static 修饰
 - 编译生成 `外部类.class ,外部类$1内部类.class`
 
 ## 匿名内部类
 适合用于只适用一次的类
 格式为：
 ```
 new 父类构造器(实参) | 接口(){
	//匿名内部类
 }
 ```
 
 - 不能是抽象类，系统创建匿名类时会立即创建 对象
 - 不能创建构造器，匿名类名类名，无法定义， 只有一个`隐式的无参构造器`,但如果是继承父类创建匿名内部类，则构造器参数与父类相似（形参）
 - 可定义实例初始化模块		

## 闭包模拟实现

内部类 可以`很方便的回调外部类的成员`，可以让变成更加灵活

非静态内部类，不仅记录`外部类的详细信息`，还保留了一个创建非静态内部类对象的一个引用，并可直接调用`外部类的private 成员`，因而可以把分静态内部类当成`面向对象领域的闭包`
1. 需求，接口`ITeachable`中有一个`work()`的接口（教师），抽象类`Programmer`中也有个 `work()`的方法（程序员），要求会`写代码(Programmer)`、`上课(Iteacher)`的老师
2. 使用闭包方式实现
```
public class TeachProprammer extends Programmer{
	//教学工作由外部类定义
	private void teach(){
	 //教师上台讲课
	}
	private class Closure implements ITeachable{
		public void work(){
			teach();
		}
	}
	//返回内部类引用，允许外部类通过该引用来回调外部类方法
	public ITeachable getCallbackReference(){
		return new Closure();
	}
}

public class Main{
	public static void main(String[] args){
		TeachProprammer t=new TeachProprammer();
		t.work();									//调用抽象类Programmer中的work方法
		t.getCallbackReference().work();			//调用匿名类的work后 调用外部类的teach方法
	}
}
```

# 枚举
1.抽象类
```java
public enum Opration{
	Plus{
		public double eval(double x,double y){
			return x+y;
		}
	}
	,MINUS{...}
	,Times{...}
	,DIVIDE{...};
	//为枚举定义抽象方法
	public abstract double eval(double x,double y);
}
```


## 对象的软、弱和虚引用

1. 强引用 ，常用的
其他引用 需要 通过java.lang.ref 提供的SoftReference.PhantomReference he WeakReference

2.软
`SoftReference`实现，一个对象只有软引用时可能被回收
当系`统内存空间足够`时，`不会`被回收
通常用于对`内存敏感`的程序中
3 弱
`WeakReference` 与软引用很像，引用级别更低，当垃圾回收机制运行时，`总是会被回收`
4 虚
 `PhantomReference `类似于`完全没有引用`，对象甚至感觉不到虚引用的存在。
 主要用于`跟踪对象被垃圾回收的状态`，不能单独使用，需要和引用队列（ReferenceQueue）联合使用

引用队列用于保存被回收对象的引用，软、弱和队列联合使用时，系统在回收被引用的对象后，将把被回收对象对应的引用增加到关联的引用队列中
虚引用在对象是否前把它对应的虚引用增加到它关联的引用队列中，使得可以在对象回收前采取行动
# java 编译器
```
javac -d . Hello.java			//-d 设置.class 文件的保存位置
//为了防止冲突生成的class 文件 必须有与包名层次相同的目录结构

java -verbose:gc TestGc //测试垃圾回收
//TestGc 类记得写 finalize() 方法

//生成jar 包
jar cf test.jar test //创建jar文件 test路径内容 生成 test.jar 
jar cvf test.jar test	//显示压缩过程
jar cvfM test.jar test	//不生成清单文件（META-INF/MANIFEST）
jar cvfm test.jar manifest.mf test 	//自定义文件清单 在原清单的基础上增加 manifest.mf 的内容
jar tf test.jar 		//查看jar包内容
jar tvf test.jar 		//查看jar包详细内容
jar xf test.jar			//解压
jar uf test.jar Hello.class 	//更新

//创建可执行的jar 包
//1. 第三方，跨平台有一定性能下降
//2. 为整个应用编辑一个批处理文件 用户双击批处理运行
java package.MainClass
//3.制作成可执行的JAR包
//安装JRE 是 jar后缀会默认以javaw.exe打开只用双击运行
//需要借助文件清单 增加主类 jar m 参数
Main-Class:test.Test

jar cvfm test.jar a.txt test

```


## 参数
```
java -Xms128m -Xmx512m Test
-Xms JVM初始内存大小
-Xmx 最大使用内存的大小（最好不要超过物理内存）
```

## 垃圾回收
1.特征
- 只负责回收堆中的对象，不回收任何物理资源（数据库连接，网络IO等资源）
- 程序无法精确控制回收，对象永久性地失去引用，系统就会在合适的时候回收它所占的内存
- 回收之前，总会调用 `finalize`方法，可能使该对象重新复活（由finalize 方法内部决定），从而取消回收
```
public void finalize(){
	staticArg=this;//去活对象重新激活
}
```

2. 状态
- 激活状态
- 去活（对象没有变量引用时）
- 死亡状态

3. 程序控制强制回收
强制回收后，系统是否进行垃圾回收依然不确定，大部分时有一些效果
```
System.gc();
或者(两者完全相同)
Runtime.getRuntime().gc();

//强制垃圾回收对象执行 finalization 方法
System.runFinalization();
或者(两者完全相同)
Runtime.getRuntime().runFinalization();
```

4.finalie 方法
Object 实例方法 `protected void finalize() throws Throwable`
特点：
- 永远不要主动调用某个对象的finalize 方法，应交给垃圾回收机制调用
- 何时调用，是否被调用具有不明确性，不要把finalize 方法当成一定会被执行的方法
- 当 jvm 去活对象的finalize 方法是 ，可能使该对象或系统中的其他对象重新变成激活状态
- 执行finalize 方法出现异常，垃圾回收机制不会报告异常，程序继续执行

#java 包 
Jar文件与Zip文件的不同是 默认包含 名为`META-INF/MANIFEST.MF`的清单文件
该文件实在生成JAR文件时由系统自动创建.
将类打包成 JAR文件给别人使用：
1. 在ClassPATH环境中增加这个JAR文件
2. java 虚拟机自动在内存中解压 
3. 把JAR文件当成一个路径

使用好处：
1.可进行数字签名，只让能能够识别签名的用户使用
2. 加快下载速度
3. 压缩
4. 包封装
5. 可移植性



# 常用的数据结构
## java 集合
java.util包下
负责保存、盛装其他数据，==>容器类
- Set				无序，不可重复
- List 				有序，可重复	
- Map				映射关系
- Queue				1.5 队列

### 集合与数组的不同
数组元素可以是基本类型的值，也可以是对象（引用数据类型）
集合只能保存对象（引用数据类型）

### 继承关系
```
Collection  <= Set,Queue,List
			Set			<=EnumSet,SortedSet，HashSet
						SortedSet			<=TreeSet
						HashSet				<=LinkedHashSet
			Queue		<=Deque,PriorityQueue(取出最小的元素)
			List 		<=LinkedList ,ArrayList,Vector
						Vector				<=Stack
Map 		<= EnumMap,WeakHashMap,IdentityHashMap,HashMap,Hashtable,SortedMap
			HashMap 	<=LinkedHashMap
			Hashtable	<=Properties
			SortedMap	<=TreeMap
```

## Iterator 接口
Enumeration 是Iterator 的古老实现
用于遍历集合元素，被称为`迭代器`，要创建一个Iterator 需要有一个被 迭代的集合。
- 在迭代过程中不能修改集合			//特别是多线程操作时
- 采用快速失败（fail-fast）机制，	//有修改 立即引发 ConcurrentModificationException 异常

使用foreah 系统异彩把集合元素的值赋给迭代变量，集合也不能被改变


计算机行业规则：`加入任何规则都必须慎之又慎，删除规则比增加规则难得多`

> 当equals 返回 true时 ，两个对象的`hashCode应该相等`

集合建议
- ArrayList 和 Vector 应使用 随机访问方法（Get）来遍历元素 ，性能更好，
- LiskedList 应使用Iterator 来遍历元素
- 需要经常执行 `插入`、`删除`操作改变List 集合，应`使用LinkedList` 集合，使用ArrayList、Vector 需要重新分配内部数组大小 ，事件开销输出LinkedList 数十倍
- `多线程` 同时访问List 考虑使用`Vector` 


IdentityHashMap 的Key 相等判断，严格相等 即 需要 `equals 返回true` 且 `hashCode 相等`

HashSet 、HashMap、HashTable 使用hash算法来决定其元素的存储（HashMap 使用Key），HashSet 、HashMap 的Hash表包含如下属性：
- 容量（capacity)						//Hash 表中桶的数量
- 初始化容量（initail capacity			//HashMap 、HashSet 都允许在构造函数中指定初始化容量
- 尺寸（Size）							//当前记录数量
- 负载因子 （Load factor)				// = size/capacity 	=0 时：空 ； 0.5 半满
- 负载极限								// 0 ～ 1   决定 最大填满程度 Hashtable=0.75 当负载因子达到负载极限达到指定值是需要 重新分配容量（一般是成倍增加） 分配空间的过程称为 ` rehashing`

## 集合操作工具来
Collections 操作Set list 和Map的工具 ，排序，查询，修改，集合对象设为不可改变，实现同步控制

## 泛型 
1.5 引入了 `参数化类型（Parameterized type） `泛型《Generic》，允许定义类、接口时指定类型参数，传入的类型参数（类型实参）
方法中带泛型形参称为   形参或`数据形参`

```
LList<String> l1=new List<~>();
List<Integer> l1=new List<~>();
l1.getClass()==l2.getClass()				//	==true
```

泛型对其所有可能的类型参数，都具有同样的行为，即类的静态变量和方法都是所有的实例间共享的，所有的`静态属性`、`静态初始代码块`，都`不允许出现泛型`;
系统中不会真正的生成泛型类，所有 instanceof 运算符后不能使用泛型类，因此 `if(list instanceof List<String>){....}` 是错误的

代码：
```
public void test(List list){....}			//List 是一个有泛型声明的接口，此处使用List 时没有传入泛型参数，引发泛型警告 ，将接口改为如下
public void test(List<Object> list){....}

List<String> strList=new List<~>();
test(strList) ;							//编译错误 List<String> 不能当成 List<Object> 对象使用，即 List<String>类 并不是List<Object>类的子类


//看数组
Interger[] ia=new Integer[5];
Number[]    na=ia;
na[0]=0.5;					//编译正常，但运行时引发 ArrayStoreException

//写成泛型
List<Integer> nlist=new ArrayList<Integer>();
List<Number> nList=ilist;	//编译错误
nlist.add(0.5);
 
```

即：使用泛型，只要代码在编译时没有出现警告，就不会遇到运行时ClassCastException　异常；
　　假设　`Foo　是　Bar　的一个子类`　那么：
		`Foo[] 也是 Bar[] 的一个子类`，
		但是 `G<Foot> 不是G<Bar>的子类`

### 泛型通配符 	`G<?>`
表示各种泛型G的父类
```
public void test(List<?> list){....}			//? 通配符，List<?> 表示各种泛型List  的父类 

//
List<?> list=new ArrayList<String>();
c.add(new Object);							//  编译错误 ，因为不知道 list 的类型 这样的写法 唯一 能放进去的 就是 null
```

经常用到的是被限制的泛型通配符 `List<? extends ParentClass>` 表示所有 ParentClass 泛型List的父类;
类型`形参的上限` `<T extends Number>` 表示实际类型是 该`上限类型`或者上限类型的`子类`;
通配符的下限 `Collection<? super T> `,例如：·`TreeSet(Comparator<? super E> c)`·.

dest 是 src 的父类
```
public static<T> T copy(Collection<T> dest,Collection<? extends T>src){....}																//不能确定 返回值是否是 T 类型 ，可能是T的子类，或者是T 类

public static<T> T copy(Collection<? super T> dest,Collection<T>src){ T last=null;for(T e :src){last=e;dest.add(e);}return last;}			//dest 必须与src类型相同，或者是src 的父类
Interger i=copy(ln,li);		//

```
 
不带类类型参数，被称作 原始类型 rawType
泛型的擦除和转换 ，把一个具有泛型的对象赋值给一个没有泛型信息的变量是，尖括号之间的类型信息都被仍掉，比如List<String>赋值给 List ,类的变量上限变为Object.


# 系统类
System 获取程序运行平台的信息
	访问操作系统底层硬件设备，需`借助 C`
		 1. 声明 `native()`  方法  类似于 `abstract` 只是方法签名，没有实现，编译该java 程序，生成`.class` 文件
		 2. 用javah 编译上面生成的class 文件，产生`.h`文件
		 3. 写一个`.cpp`文件实现native 方法，其中需要包含上面的`.h`文件(.h 文件中包含了JDK带的jni.h)
		 4. 将`.cpp` 文件编译成动态链接库文件。
		 5. 在java中用 System 的LoadLibray() 方法或者 Rumtime 的 LoadLibray() 方法加载动态链接库文件，
		 6. 在java 中就可以调用这个 native() 方法了。
		 
Runtime 类  java 运行时的环境，每个java 程序都有一个与之对应的Runtime  实例，应用程序通过该对象与其运行时环境相连。
应用程序不能创建Runtime实例，可以通过getRuntime()方法获得与之相关的实例。
可以获取处理器数量，内存信息等。
		 
		 
# 其他常用类
## string 不可变类

`StringBuffer`  可变字符串，线程安全
`StringBuilder` 可变，1.5 新增，


`String a="AAAA";`						//左边的是引用变量是可以改变的，右面的是创建的对象不可以改变； AAAA 叫做`字面值`;
`String str="A"+"B"+"C";`				// 额外产生了2个字符串常量 ：AB	的临时变量			ABC 的临时变量
`StringBuffer` 或者 `StringBuilder` 可避免上述问题；

常量池： 编译期被确定并被保存在已编译的 `.class `文件中的一些数据；`包含 类、方法、接口中的常量` 也包含 `字符串常量`
Java 会确认每个`字符串常量` `只有一个`,一个字符串由`多个字符串常量`连接而成，它本身已是字符串常量
`new String()` 不是字符串常量


随机函数：Random 使用一个`48bit `的种子，当两个Random 对象种子相同时，它们产生相同的数字序列，使用`默认种子`构造Random对象时，它们属于同一个种子。

## DigDecimal 类
问题：float、double 两种基本数据类似容易引起`精度丢失`,尤其是进行算术运算的时候（很多语言都有这样的问题），比如：
```java
System.out.println((0.05+0.01));		//0.060000000000000005
System.out.println((1+0.42));			//0.580000000000000001
System.out.println((4.015*100));		//401.4999999999999994
System.out.println((123.3/100));		//1.232999999999999999
```

为精确表示、计算浮点数，java 提供了BigDecimal 类，该类`不推荐`使用 构造器 `new BigDecimal(0.1)//0.00000000000000005551115123125782;` 因为0.1 无法精确表示double浮点数，所有传入BigDecimal 不会恰巧等于 0.1；
因此建议使用 String 的构造器 `new Bigdecima('0.1');`,如果必须是使用 doublce 可以使用 `BigDecimal.valueOf(doublce value)`;

## 日期时间类
Date 存在一些设计缺陷，java 提供Calendar 类来更好的处理日期和时间，
时区，地球被划分为24个时区，北京为东八区，程序中对时间的默认实现是以`格林威治`时间为标准,这样产生了8个小时的时间差，为让程序更通用，可以使用TimeZone来设置程序中事件所属失去；
 
## 程序国际化 Internationalization 简称 I18N
`I` : 单词的第一个字母
`18`: 中间省略18个字母
`n` : 最后一个字母


`Localization --> L10N ` 本地化

根据不同客户端语言环境，使用响应不同的语言界面；
java 语言内核基于 `Unicode2.1`编码集，已具有国际化和本地化的特征和API

国际化主要通过：： 实现：
- java.util.ResourceBundle 				用于加载一个国家的语言资源包；
- java.util.Locale						用于封装一个特定国家/区域、语言环境
- java.text.MessageFormat				用户格式化带占位符的字符串

资源文件命名可以有以下三种格式：
- baseName_language_country.properties
- baseName_language.properties
- baseName.properties



# 图形化编程
java 使用 AWT和Swing 完成图形化用户界面编程，
AWT 抽象窗口工具集（Abstract Window Toolkit）-是->  Sun最早提供GUI库
后来提供  Swing， 通过使用ATW 和Swing来实现图像化编程。

AWT 特点：
- 界面显得丑陋，功能有限
- 为迎合所有主流操作系统的界面设计，AWT 组件只能使用这些操作系统上图形界面组件的交集，做多只能使用四种字体
- 非常笨拙，并非面向对象编程；

1996 年Netscape 开发一套工作方式完全独立的GUI库，简称 IFC（Internet Foundation Classes ）该GUI所有图像组件都绘制在空白窗口上，只有窗口需要借助操作系统的窗口实现，
后 SUN 和Netscape 合作完善该方法，推出 Swing
Awt、Swing、辅助功能API、2D API 和 拖放API 组成 JFC （JAVA Foundation Classes -->java 基础库）,

Swing 全面替换了Java1.0 中的ATW 组件，保留java 1.1 Awt 的事件模型，

## Applet 
`java.applet.Applet` 是 `java.swing.JApplet`的父类。 
是java 应用程序的一种，通常需要嵌入 html页面，由客户端浏览器下载并执行，该程序存在的限制
- 不能访问本地磁盘，Java允许Applet 提供数字签名，你可以选择让有数字签名的Applet 访问你的磁盘
- Applet 不能调用客户端的程序，
- applet 不能打开Socket 与外界通信 ，可以播放声音、显示图片，接收键盘鼠标等操作。

 






