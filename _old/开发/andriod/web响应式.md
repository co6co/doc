---
layout: post
title: web响应式
subtitle:
date:       2023-04-24 10:40:46
categories: [andriod]
tags: [andriod,web响应式]
---


# 1. web
## 1.1 非阻塞异步编程模型
相应式编程为了解决什么问题：
假设一个用户要购物下单，我们需要先获取商品详细和用户的地址，然后根据这些信息进行下单操作：
```
data class Goods(val id:Long, val name:String,val stock:Int)
data class Address(val userId:Long,val location:String)

fun getGoodsFromDB(goodsId:Long):Goods{	//获取商品详细
	Thread.sleep(1000)			//模拟IO操作
	return Goods(goodsId,"深入Kotlin",10)

}
fun getAddressFromDB(userId:Long):Address{	//获取地址详情
	Thread.sleep(1000)			//模拟IO操作
	return Address(userId,"杭州")
}

fun doOrder(goods:Goods,address:Address):Long{ //进行下单操作
	Thread.sleep(1000)			//模拟IO操作
	return 1L
}

fun order(goodsId:Long,userId:Long){
	val goods = getGoodsFromDB(goodsId)
	val address = getAddressFromDB(userId)
	doOrder(goods,address)
}
```

这是我们常用的做法，缺点是：他是一种同步阻塞方式，获取商品和获取地址两个没有关联的
操作设计成并行可以拥有更快的响应速度；

要实现异步非阻塞Kotlin有两种方法：一为利用Java标准库中的`CompletableFuture`，另一种为使用协程来实现：
- CompletableFuture
```
fun getGoodsFromDB(goodsId:Long):CompletableFuture<Goods>{
	return CompletableFuture.supplyAsync{	//返回 CompletableFutrue<Goods>
		Thread.sleep(1000)			//模拟IO操作
	    Goods(goodsId,"深入Kotlin",10)
	}
}

fun getAddressFromDB ...
...
...

fun main(args:Array<String>){
	val goodsF =getGoodsFromDB(1)
	val addressF =getAddressFromDB(1)
	CompletableFutrue.allOf(goodsF,addressF).thenApply{ //保证前两个IO操作完成
		Stream.of(goodsF,addressF).map{it.join()}.collect(Collectors.toList<Array>)
		
	}.thenApply{
		doOrder(it[0] as Goods,it[1] as Address)
	}.join() 
}
 
```

在java中我们确实可以使用CompletableFuture 来写异步非阻塞代码，但CompletableFuture 操作不那么直观，还借助了Stream来得到结果；

- 使用RxKotlin进行响应式编程
一种更加直观异步非阻塞时编程的解决方案是利用RxJava，Rx系列的类库一个主要的作用是提供统一的接口来帮助我们更方便地处理异步数据流，其他Rxjava提供了对Java的支持；
RxKotlin它的实现基于RxJava，不过RxKotlin还增加了一些Kotlin独有的特性；
```
val threadCount=Runtime.getRuntime().availableProcessors()
val threadPoolExecutor= Executors.newFixedThreadPool(threadCount)
val schedule = Scheduler.from(threadPoolExecutor)

fun getGoodsFromDB(goodsId:Long):Observable<Goods>{
	return Observable.defer{
		Thread.sleep(1000)
		Observable.just(Goods(GoodsId,"klsss"，10))
	}
}

fun getAddressFromDB(userId:Long):Observable<Address>{
	return Observable.defer{
		Thread.sleep(1000)
		Observable.just(Address(userId,"杭州"))
	}
}

fun rxOrder(goodsId:Long,userId：Long){
	var goods：Goods?=null
	var address：Address?=null
	val goodsF =getGoodsFromDB(1).subscribeOn(scheduler)
	val addressF =getAddressFromDB(1).subscribeOn(scheduler)
	
	Observable.merge(goodsF,addressF).subscribeBy{
		onNext={
			when(it){
				is Goods ->goods =it
				is Address ->address =it
			}
		},
		onComplete={
			doOrder(goods!!,address!!)
		}
	}

}
```

- 代码多了很多，但将异步编程变得优雅、直观，不用对每个异步请求都执行一个回调，同时还可以组合多个异步任务；
- 不需要写多线程代码，只需指定响应的策略便可使用多线程的功能
- Java 6及以上版本都可用；

# 2. 支持相应式编程
Spring5 版本以前它并不是原生支持相应式编程的，主要是底层容器的限制，Tomcat等容器在Servlet3.1支持AyncIO之前，并不能做到真正的异步非阻塞，而集成一些支持异步非阻塞的容器比如Netty
又相当比较麻烦。
然而在Srping5发布会，你可以轻松选择自己所需的web容器，比如Tomcat 或者Netty等，这给Spring支持响应式编程提供了底层基础。
传统的Spring mvc并不支持相应式编程，故Spring5引入了全新的Web框架-Spring Webflux。

Spring Webflux 主要帮助我们在框架层面实现响应式编程，它不再使用传统基于Servlet实现的HttpServletRequet和HttpServletResponse，而是采用全新的ServerRequest和ServerResponse。
同时请求的返回数据类型为Flux，这是一种响应式的数据流类型，和上文提到的Observable一样；

Spring 5 并没有使用RxJava2作为程序相应式类库，默认是Reactor库；
RxJava库早于Reactor诞生，所有RxJava一开始处于相应式编程的探索阶段，java并未提出响应式编程规范，
Rxjava 受限于Rxjava遗留的历史包袱，有些方面使用起来并不是很方便；而Reactor完全基于相应式流规范设计和实现的类库，同时JDK最低版本是JDK8,
可以提供JDK8 提供的流操作。

Spring Webflux 基础数据类型：
- Mono 代表0~1 个元素比如Mono<User>代表返回流中只有一个数据或者空数据
- Flux 代表0~N个元素


Spring5 除了引入Spring Webflux来提供响应式编程外，它还适配Kotlin

2.1 适配Kotlin
Kotlin 虽然一直在安卓开发中被广泛采用，但在Web开发中却很少见， 一个很重要的原因就是没有一个好的web框架适配它，
虽然Spring 5之前已经又了Kto，Javalin等框架支持Kotlin，但由于相对比较小众，并没有被广泛应用；
而Srping5 全面适配Kotlin将会是Kotlin在Web开发中大展拳脚的一好机会。

基于Spring5 和Lotlin编写响应式Web应用未来可能是一种趋势。
同时Spring还支持KotlinDSL，让我们开发应用时配置更加灵活。

# 3. 函数式路由
路由配置时一个Web框架的特色，Spring从最早的Xml配置到后来的注解配置，现在还支持函数式路由。
不探讨注解路由和函数式路由的好坏
随着微服务及模块化程序开发趋势的发展，路由分模块化统一管理是一个需求，但用传统的注解方式很难做到，
Spring 5 最新支持的函数式路由却可以实现该功能，结合Kotlin DSL 语法非常简洁：
```
@Component
class UserHandler{  //类中无路由信息
	fun getUser(){}
	fun addUser(){}
	fun updateUser(){}

}
@Component
class CustomerHandler{  
	fun getCustomerH(){}
	fun addCustomerH(){}
	fun updateCustomerH(){} 
}

@Configuration
class Routs(userHandler:UserHandler,customerHander:CustomerHandler){
	//定义路由类统一管理
	@Bean
	fun userRouter()=router{  //不同类的路由分开管理
		"user".nest {
			GET("/getUser").nest{
				accept(APPLICATION_JSON,userHandler::getUser)
			}
			POST("/addUser").nest{
				accept(APPLICATION_JSON,userHandler::addUser)
			}
			PUT("/updateUser").nest{
				accept(APPLICATION_JSON,userHandler::updateUser)
			}
		}
	}
	
	@Bean
	fun customerRouter()=router{
		"customer".nest{
			GET(...).nest ..
			
		}
	}
}
```

# 4 数据库异步驱动
如果一个请求在执行中又一部分是同步阻塞的，那么整个系统应用就不能算异步非阻塞，所有数据库操作也必须是异步非阻塞。

即程序于数据库通讯的驱动需要支持异步非阻塞，如果Spring支持的MongoDB、Redis等，
然而，我们很多场景使用Mysql，由于使用的JDBC驱动时同步阻塞，因此我们使用Mysql需要一个异步非阻塞的架构。
- Scale上 的异步驱动 postgresql-async 全异步，基于Netty实现 同时支持Mysql和Postgresql
- Quill 作者申明不再维护

Kotlin社区成员将项目用Kotlin重写名为 `jasync-sql` 基于 Java8 的CompletableFuture ，完全适配Java及Kotlin

jasync-sql 与 Spring webflux 结合：
```
//创建连接
Connection con=new MySQLConnection(
	new Configuration(
		"root",
		"localhost"
		3306,
		"123456",
		"test"
	)
)

CompletableFuture<Connection> conFuture=con.connect()
CompletableFutrue<QueryResult> queryResult=connect.sendPrepareS
val result:Mono<QueryResult> =Mono.fromFuture(queryResult)
```