---
layout: post
title: Netty_2
subtitle:
date:       2021-11-22 15:10:21
categories: [JAVA]
tags: [JAVA,Netty_2]
---


# 1. 概述
简化你的应用程序代码，同时最大限度地提高性能和可维护性。

Netty的异步编程模型是建立在Future和回调的概念之上的， 而将事件派发到ChannelHandler的方法则发生在更深的层次上

Netty通过触发事件将Selector从应用程序中抽象出来，消除了所有本来将需要手动编写的派发代码。
在内部，将会为每个Channel分配一个EventLoop，用以处理所有事件：
- 注册感兴趣的事件
- 将事件派发给ChannelHandler；
- 安排进一步的动作。

EventLoop本身只由一个线程驱动，基于Java NIO的异步的和事件驱动的实现,
Netty也包含了一组设计模式，将应用程序逻辑从网络层解耦，简化了开发过程，同时也最大限度地提高了可测试性、模块化以及代码的可重用性

![netty架构](/static/开发/JAVA/imgs/netty架构.jpeg)

## 1.1 零拷贝
零拷贝（zero-copy）是一种目前只有在使用NIO和Epoll传输时才可使用的特性。
它使你可以快速高效地将数据从文件系统移动到网络接口，
而不需要将其从内核空间复制到用户空间，
其在像FTP或者HTTP这样的协议中可以显著地提升性能。
但是，并不是所有的操作系统都支持这一特性。
特别地，它对于实现了数据加密或者压缩的文件系统是不可用的——只能传输文件的原始内容。反过来说，传输已被加密的文件则不是问题。

## 1.2 CPU限定的代码
永远不要在Netty的I/O线程上执行任何非CPU限定的代码——你将会从Netty偷取宝贵的资源，并因此影响到服务器的吞吐量。

HttpRequest和HttpChunk都可以通过切换到另一个不同的线程，来将执行流程移交给请求处理器。当请求处理器不是CPU限定时，就会发生这样的情况，不管是因为它们访问了数据库，还是执行了不适合于本地内存或者CPU的逻辑。
当发生线程切换时，所有的代码块都必须要以串行的方式执行；否则，我们就会冒风险，对于一次上传来说，在处理完了序列号为n的HttpChunk之后，再处理序列号为n -1的HttpChunk必然会导致文件内容的损坏。（我们可能会交错所上传的文件的字节布局。）为了处理这种情况，我创建了一个自定义的线程池执行器，其确保了所有共享了同一个通用标识符的任务都将以串行的方式被执行。
 
 
## 1.3 Future功能
异步操作的结果,
`get`方法获取操作结果，如果操作尚未完成，则会同步阻塞当前调用的线程；
	带超时时间的get方法获取结果
`isDone`方法可以判断当前的异步操作是否完成，
	如果完成，无论成功与否，都返回true，否则返回false。
`cancel`可以`尝试`取消异步操作，它的结果是未知的，
	如果操作已经完成，或者发生其他未知的原因拒绝取消，取消操作将会失败。

ChannelFuture有两种状态：uncompleted和completed。当开始一个I/O操作时，一个新的ChannelFuture被创建，此时它处于uncompleted状态——非失败、非成功、非取消，因为I/O操作此时还没有完成。一旦I/O操作完成，ChannelFuture将会被设置成completed，它的结果有如下三种可能。
```
◎ 操作成功；
◎ 操作失败；
◎ 操作被取消。
```
获取操作结果、添加事件监听器、取消I/O操作、同步等待等。
当I/O操作完成之后，I/O线程会回调ChannelFuture中GenericFutureListener的operationComplete方法，
并把ChannelFuture对象当作方法的入参。
如果用户需要做上下文相关的操作，需要将上下文信息保存到对应的ChannelFuture中。

`不要在ChannelHandler`中调用`ChannelFuture的await（）方法`，这会导致死锁。
原因是发起I/O操作之后，由I/O线程负责异步通知发起I/O操作的用户线程，
如果I/O线程和用户线程是同一个线程，就会导致I/O线程等待自己通知操作完成，
这就导致了死锁，这跟经典的两个线程互等待死锁不同，属于自己把自己挂死。

## 1.4 Promise
异步I/O操作结果的通知回调类

setSuccess方法,可能存在I/O线程和用户线程同时操作Promise，所以设置操作结果的时候需要加锁保护，防止并发操作。

无论Future还是Promise，都强烈建议读者通过增加监听器Listener的方式接收异步I/O操作结果的通知，而不是调用wait或者sync阻塞用户线程。


# 2. Chanel ----  Socket
bind()、connect()、read()和write()		-- 依赖于底层网络传输 ,基本构造是 `Socket`
Java Nio 的一个基本构造，代表一个实体（硬件设备、文件、套接字）开放连接
可以把Channel看作是传入（入站）或者传出（出站）数据的载体。因此，它可以被打开或者被关闭，连接或者断开连接。

Channel也是拥有许多预定义的、专门化实现的广泛类层次结构的根
```
EmbeddedChannel；
LocalServerChannel；
NioDatagramChannel；
NioSctpChannel；
NioSocketChannel

```


聚合了一组功能，包括但不限于网路的读、写，客户端发起连接，主动关闭连接，链路关闭，获取通信双方的网络地址等。它也包含了Netty框架相关的一些功能，包括获取该Chanel的EventLoop，获取缓冲分配器ByteBufAllocator和pipeline等。

Channel需要注册到EventLoop的多路复用器上，用于处理I/O事件，通过eventLoop（）方法可以获取到Channel注册的EventLoop。
EventLoop本质上就是处理网络读写事件的Reactor线程。
通过metadata（）方法就可以获取当前Channel的TCP参数配置。
Unsafe接口实际上是Channel接口的辅助接口，它`不应该被用户代码直接调用`。实际的I/O读写操作都是由Unsafe接口负责完成的。

Netty所提供的广泛功能只依赖于少量的接口
 

|方　法　名			|描　　述|
|--|--|
|eventLoop			|返回分配给Channel的EventLoop|
|pipeline			|返回分配给Channel的ChannelPipeline|
|isActive			|如果Channel是活动的，则返回true。活动的意义可能依赖于底层的传输。例如，一个Socket传输一旦连接到了远程节点便是活动的，而一个Datagram传输一旦被打开便是活动的|
|localAddress		|返回本地的SokcetAddress|
|remoteAddress		|返回远程的SocketAddress|
|write				|将数据写到远程节点。这个数据将被传递给ChannelPipeline，并且排队直到它被冲刷|
|flush				|将之前已写的数据冲刷到底层传输，如一个Socket|
|writeAndFlush		|一个简便的方法，等同于调用write()并接着调用flush()|
 
生命周期：
- `ChannelUnregistered`	
	Channel已经被创建，但还未注册到EventLoop
- `ChannelRegistered`
	Channel已经被注册到了EventLoop
- `ChannelActive`
	Channel处于活动状态（已经连接到它的远程节点）。它现在可以接收和发送数据了
- `ChannelInactive`
  Channel没有连接到远程节点
 
 ChannelRegistered--> ChannelActive-->ChannelInactive-->ChannelUnregistered
 
状态发生改变时，将会生成对应的事件，
事件将会被转发给ChannelPipeline中的ChannelHandler

## 2.1 ChannelFuture	---- 异步通知
提供了另一种(还有一种是回调)在操作完成时通知应用程序的方式，
是异步操作的结果的占位符
Netty提供了它自己的实现——`ChannelFuture`(JDK预置interface java.util.concurrent.Future只允许手动检查)；

```
Channel channel = ...;
// Does not block
ChannelFuture future = channel.connect(     				//--  异步地连接到远程节点
    new InetSocketAddress("192.168.0.1", 25));
```
FutureListener:

``` 
future.addListener(new ChannelFutureListener() {   			 //← --  注册一个ChannelFutureListener，以便在操作完成时获得通知
    @Override
    public void operationComplete(ChannelFuture future) { 	 //← --  ❶ 检查操作的状态
       if (future.isSuccess()){ 
            ByteBuf buffer = Unpooled.copiedBuffer( 		 //← -- 如果操作是成功的，则创建一个ByteBuf以持有数据
               "Hello",Charset.defaultCharset());
           ChannelFuture wf = future.channel()
                .writeAndFlush(buffer);   					 //← -- 将数据异步地发送到远程节点。返回一个ChannelFuture
            ....
        } else {
            Throwable cause = future.cause();　				 //　← --　如果发生错误，则访问描述原因的Throwable
            cause.printStackTrace();
        }
    }
});
```

Netty提供了大量预定义的可以开箱即用的ChannelHandler实现，包括用于各种协议（如HTTP和SSL/TLS）的ChannelHandler

`addListener()`方法注册了一个ChannelFutureListener，以便在某个操作完成时（无论是否成功）得到通知。
可以将ChannelFuture看作是将来要执行的操作的结果的占位符。执行则可能取决于若干的因素,可以肯定的是它将会被执行,
`同一个Channel`的操作都被保证其将以它们被调用的`顺序被执行`。

# 3. EventLoopGroup	--- 控制流、多线程处理、并发
EventLoop定义了Netty的核心抽象,用于处理连接的生命周期中所发生的事件
NioEventLoopGroup

Channel、EventLoop、Thread以及EventLoopGroup之间的关系
创建Channel，将Channel注册到EventLoops，在整个生命周期内都是用EventLoop处理I/O 事件，
- 一个EventLoopGroup包含一个或多个EventLoop；
- 一个EventLoop在它的生命周期内只和一个Thread绑定；
- 所有的EventLoop处理的I/O事件都将在它专有的Thread上被处理；
- 一个Channel在它的生命周期内注册一个EventLoop；
- 一个EventLoop可能会被分配给一个或多个Chanel。
 
一个给定Channel的I/O操作都是由相同的Thread执行的，实际上消除了对于同步的需要。

[结构图](/static/开发/JAVA/imgs/EventLoop.png)

一个EventLoop将由一个永远都不会改变的Thread驱动，任务（Runnable或者Callable）可以直接提交给EventLoop实现，
根据配置和可用核心的不同，可能会创建多个EventLoop实例用以优化资源的使用，并且单个EventLoop可能会被指派用于服务多个Channel。


Java 5之前，任务调度是建立在`java.util.Timer`类之上的，其使用了一个后台Thread，
随后，JDK提供了java.util.concurrent包，它定义了`interface ScheduledExecutorService`
```
cheduledExecutorService executor = Executors.newScheduledThreadPool(10);   ← --  创建一个其线程池具有10 个线程的ScheduledExecutorService

ScheduledFuture<?> future = executor.schedule(
　　new Runnable() {　  ← --  创建一个R unnable，以供调度稍后执行
　　@Override
　　public void run() {
　　　　System.out.println("60 seconds later");  ← --  该任务要打印的消息
　　}
}, 60, TimeUnit.SECONDS);  ← -- 调度任务在从现在开始的60 秒之后执行
...
executor.shutdown();   ← -- 一旦调度任务执行完成，就关闭ScheduledExecutorService 以释放

```

ScheduledExecutorService的实现具有局限性，例如，事实上作为线程池管理的一部分，将会有额外的线程创建。如果有大量任务被紧凑地调度，那么这将成为一个瓶颈。
Netty通过Channel的EventLoop实现任务调度解决了这一问题 `schedule` 与 `scheduleAtFixedRate`
```
Channel ch = ...
ScheduledFuture<?> future = ch.eventLoop().schedule(  ← --  创建一个Runnable以供调度稍后执行
　　new Runnable() { 
　　@Override
　　public void run() { 							 ← --  要执行的代码
　　　　System.out.println("60 seconds later");　
　　}
}, 60, TimeUnit.SECONDS);　 						 ← --  调度任务在从现在开始的60 秒之后执行


Channel ch = ...
ScheduledFuture<?> future = ch.eventLoop().scheduleAtFixedRate(   ← -- 创建一个Runnable，以供调度稍后执行 
　　new Runnable() {
　　@Override
　　public void run() {
　　　　System.out.println("Run every 60 seconds");　  ← -- 这将一直运行，直到ScheduledFuture 被取消
　　}
}, 60, 60, TimeUnit.Seconds);　 					    ← -- 调度在60 秒之后，并且以后每间隔60 秒运行



//取消调度
ScheduledFuture<?> future = ch.eventLoop().scheduleAtFixedRate(...);   ← --  调度任务，并获得所返回的ScheduledFuture
// Some other code that runs...
boolean mayInterruptIfRunning = false;
future.cancel(mayInterruptIfRunning);　 ← --  取消该任务，防止它再次运行
```

卓越性能取决于对于·`当前执行的Thread的身份的确定` ,确定它是否是分配给当前Channel以及它的EventLoop的那一个线程。
正是支撑EventLoop的线程，那么所提交的代码块将会被（直接）执行。否则，EventLoop将调度该任务以便稍后执行，并将它放入到内部队列中。当EventLoop下次处理它的事件时，它会执行队列中的那些任务/事件。

每个EventLoop都有它`自已的任务队列`

如果必须要进行阻塞调用或者执行`长时间运行的任务`，我们建议使用一个专门的`EventExecutor`

## 3.1 线程的分配
1. 异步传输
使用了少量的EventLoop,它们可能会被多个Channel所共享。这使得可以通过尽可能少量的Thread来支撑大量的Channel，而不是每个Channel分配一个Thread。
如：一个EventLoopGroup，它具有3个固定大小的EventLoop（每个EventLoop都由一个Thread支撑）。
	在创建EventLoopGroup时就直接分配了EventLoop（以及支撑它们的Thread），以确保在需要时它们是可用的。
	
![ EventLoopThread](/static/开发/JAVA/imgs/EventLoopThread.png)

一旦一个Channel被分配给一个EventLoop，它将在它的`整个生命周期`中都使用这个`EventLoop`（以及相关联的Thread）
一个EventLoop通常会被用于支撑多个Channel，所以对于所有相关联的Channel来说，`ThreadLocal都将是一样的`。
这使得它对于实现状态追踪等功能来说是个糟糕的选择。

2. 阻塞传输

每一个Channel都将被分配给一个EventLoop（以及它的Thread）

![ OIO EVENTLOOP](/static/开发/JAVA/imgs/OIOEVENTLOOP.png) 

每个Channel的I/O事件都将只会被一个Thread（用于支撑该Channel的EventLoop的那个Thread）处理


## 3.2 线程模型
### 3.2.1 Reactor单线程模型.
所有的I/O操作都在同一个NIO线程上面完成。NIO线程的职责如下。
- ◎ 作为NIO服务端，接收客户端的TCP连接；
- ◎ 作为NIO客户端，向服务端发起TCP连接；
- ◎ 读取通信对端的请求或者应答消息；
- ◎ 向通信对端发送消息请求或者应答消息。

使用的是异步非阻塞I/O，所有的I/O操作都不会导致阻塞，理论上一个线程可以独立处理所有I/O相关的操作。从架构层面看，一个NIO线程确实可以完成其承担的职责。
通过Acceptor类接收客户端的TCP连接请求消息，当链路建立成功之后，通过Dispatch将对应的ByteBuffer派发到指定的Handler上，进行消息解码

在一些小容量应用场景下，可以使用单线程模型。但是这对于高负载、大并发的应用场景却不合适。

## 3.2.2 Reactor多线程模型
Rector多线程模型与单线程模型最大的区别就是有`一组NIO线程`来处理`I/O操作`

- ◎有专门一个 NIO 线程——Acceptor 线程用于监听服务端，接收客户端的 TCP 连接请求。
- ◎ 网络I/O操作——读、写等由一个NIO线程池负责，线程池可以采用标准的JDK线程池实现，它包含一个任务队列和 N 个可用的线程，由这些 NIO 线程负责消息的读取、解码、编码和发送。
- ◎ 一个NIO线程可以同时处理N条链路，但是一个链路只对应一个NIO线程，防止发生并发操作问题。

Reactor多线程模型可以满足性能需求。但是，在个别特殊场景中，`一个NIO线程负责监听和处理所有的客户端连接可能会存在性能问题`.
例如并发百万客户端连接，或者服务端需要对客户端握手进行安全认证，但是认证本身非常损耗性能。

## 3.2.3 主从Reactor多线程模型
服务端用于`接收客户端连接`的不再是一个单独的NIO线程，而是一个`独立的NIO线程池`。
Acceptor接收到客户端TCP连接请求并处理完成后（可能包含接入认证等），
将`新创建的SocketChannel`注册到`I/O线程池（sub reactor线程池）`的某个I/O线程上，
由它负责SocketChannel的读写和编解码工作。
Acceptor线程池仅仅用于客户端的登录、握手和安全认证，一旦链路建立成功，
就将链路注册到后端subReactor线程池的I/O线程上，由I/O线程负责后续的I/O操作。

## 3.2.4 Netty的线程模型
通过设置不同的启动参数，Netty可以同时支持Reactor单线程模型、多线程模型和主从Reactor多线层模型。
服务端启动的时候，创建了`两个NioEventLoopGroup`，它们实际是两个`独立的Reactor线程池`。
一个用于接收客户端的TCP连接，另一个用于处理I/O相关的读写操作，或者执行系统Task、定时任务Task等。
接收客户端的TCP请求职责：
（1）接收客户端TCP连接，初始化Channel参数；
（2）将链路状态变更事件通知给ChannelPipeline。

Netty处理I/O操作的Reactor线程池职责：
（1）异步读取通信对端的数据报，发送读事件到ChannelPipeline；
（2）异步发送消息到通信对端，调用ChannelPipeline的消息发送接口；
（3）执行系统调用Task；
（4）执行定时任务Task，例如链路空闲状态监测定时任务。

通过调整线程池的线程个数、是否共享线程池等方式，Netty的Reactor线程模型可以在单线程、多线程和主从多线程间切换

表面上看，·`串行化设计`似乎CPU利用率不高，并发程度不够。但是，通过调整NIO线程池的线程参数，可以同时启动多个串行化的线程并行运行，这种局部无锁化的串行线程设计相比一个队列—多个工作线程的模型性能更优。
Netty的NioEventLoop读取到消息之后，直接调用ChannelPipeline的fireChannelRead（Object msg）。
只要用户不主动切换线程，一直都是由NioEventLoop调用用户的Handler，期间不进行线程切换。这种串行化处理方式避免了多线程操作导致的锁的竞争，从性能角度看是最优的。

## 3.3 Netty的多线程编程最佳实践

1. 创建两个NioEventLoopGroup，用于逻辑隔离NIO Acceptor和NIO I/O线程。
2. 尽量不要在ChannelHandler中启动用户线程（解码后用于将POJO消息派发到后端业务线程的除外）。
3. 解码要放在NIO线程调用的解码Handler中进行，不要切换到用户线程中完成消息的解码。
4. 如果业务逻辑操作非常简单，没有复杂的业务逻辑计算，没有可能会导致线程被阻塞的磁盘操作、数据库操作、网路操作等，可以直接在NIO线程上完成业务逻辑编排，不需要切换到用户线程。
5. 如果业务逻辑处理复杂，不要在NIO线程上完成，建议将解码后的POJO消息封装成Task，派发到业务线程池中由业务线程执行，以保证NIO线程尽快被释放，处理其他的I/O操作。
# 4. 引导器
为应用程序的网络层配置提供了容器，涉及将一个进程绑定到某个指定的端口

用例称作引导一个服务器，后面的用例称作引导一个客户端，
有两种类型的引导：一种用于客户端（简单地称为Bootstrap），而另一种（ServerBootstrap）用于服务器。

服务器致力于使用一个父Channel来接受来自客户端的连接，并创建子Channel以用于它们之间的通信；
而客户端将最可能只需要一个单独的、没有父Channel的Channel来用于所有的网络交互。


引导一个客户端只需要`一个EventLoopGroup`，但是一个ServerBootstrap则需要`两个`（也可以是同一个实例）
服务器需要`两组不同的Channel`
第一组将只包含一个`ServerChannel`		---自身的已绑定到某个本地端口的正在监听的套接字
第二组将包含所有已创建的用来`处理传入客户端连接`（对于每个服务器已经接受的连接都有一个）的Channel

![两个EventLoopGroup的服务器](/static/开发/JAVA/imgs/server.png)

与ServerChannel相关联的EventLoopGroup将分配一个负责为传入连接请求创建Channel的EventLoop。
一旦连接被接受，第二个EventLoopGroup就会给它的Channel分配一个EventLoop。

group
	NioEventLoopGroup

channel
每个通道都拥有一个与之相关联的ChannelPipeline，持有一个ChannelHandler的实例链
NioServerSocketChannel

```handler										#挂钩到事件的生命周期，并且提供自定义的应用程序逻辑，有助于保持业务逻辑与网络处理代码的分离
	new ChannelInitializer<SocketChannel>()
		initChannel(SocketChannel ch)
			ch.pipeline().addLast(new EchoClientHandler());
			
```
会把对它的方法的调用转发给链中的下一个Channel-Handler
如果exceptionCaught()方法没有被该链中的某处实现，那么所接收的异常将会被传递到ChannelPipeline的尾端并被记录
应用程序应该提供至少有一个实现了exceptionCaught()方法的ChannelHandler
针对不同类型的事件来调用ChannelHandler

 
## 4.1. 引导过程中添加多个ChannelHandler
调用了handler()或者childHandler()方法来添加单个的ChannelHandler  简单的应用程序来说可能已经足够了，但是它不能满足更加复杂的需求
部署尽可能多的ChannelHandler。但是，如果在引导的过程中你只能`设置一个ChannelHandler`,针对于这个用例Netty提供了一个特殊的`protected abstract void initChannel(C ch) throws Exception;` 将多个ChannelHandler添加到一个ChannelPipeline中的简便方法

```
ServerBootstrap bootstrap = new ServerBootstrap();　 					← --  创建ServerBootstrap 以创建和绑定新的Channel 
bootstrap.group(new NioEventLoopGroup(), new NioEventLoopGroup())　 		← --  设置EventLoopGroup，其将提供用以处理Channel 事件的EventLoop
　　.channel(NioServerSocketChannel.class)　 								← --   指定Channel 的实现
　　.childHandler(new ChannelInitializerImpl());　  						← -- 注册一个ChannelInitializerImpl 的实例来设置ChannelPipeline 
 ChannelFuture future = bootstrap.bind(new InetSocketAddress(8080)); 	 ← -- 绑定到地址
future.sync();
final class ChannelInitializerImpl extends ChannelInitializer {[10] 	 ← -- 用以设置ChannelPipeline 的自定义ChannelInitializerImpl 实现
　　@Override
　　protected void initChannel(Channel ch) throws Exception { 			← -- 将所需的ChannelHandler添加到ChannelPipeline
　　　　ChannelPipeline pipeline = ch.pipeline();
　　　　pipeline.addLast(new HttpClientCodec());
　　　　pipeline.addLast(new HttpObjectAggregator(Integer.MAX_VALUE));
　　}
}

```

## 4.2. 引导DatagramChannel

Netty提供了各种DatagramChannel的实现。唯一区别(与TCP相比)就是，不再调用connect()方法，而是只调用bind()方法
```
Bootstrap bootstrap = new Bootstrap();　 								← --   创建一个Bootstrap 的实例以创建和绑定新的数据报Channel
bootstrap.group(new OioEventLoopGroup()).channel(  						← -- 设置EventLoopGroup，其提供了用以处理Channel 事件的EventLoop 
　　OioDatagramChannel.class).handler(　 									← -- 指定Channel的实现
　　new SimpleChannelInboundHandler<DatagramPacket>(){　 					← -- 设置用以处理Channel 的I/O 以及数据的Channel-InboundHandler
　　　　@Override
　　　　public void channelRead0(ChannelHandlerContext ctx,
　　　　　　DatagramPacket msg) throws Exception {
　　　　　　// Do something with the packet
　　　　}
　　}
);
ChannelFuture future = bootstrap.bind(new InetSocketAddress(0));   		← -- 调用bind()方法，因为该协议是无连接的
future.addListener(new ChannelFutureListener() {
　　@Override
　　public void operationComplete(ChannelFuture channelFuture)
　　　　throws Exception {
　　　　if (channelFuture.isSuccess()) {
　　　　　　System.out.println("Channel bound");
　　　　} else {
　　　　　　System.err.println("Bind attempt failed");
　　　　　　channelFuture.cause().printStackTrace();
　　　　}
　　}
});

```

## 4.3. 优雅关闭
你也可以让JVM在退出时处理好一切，但是这不符合优雅的定义，优雅是指干净地释放资源。

- 需要关闭EventLoopGroup
	处理任何挂起的`事件`和`任务`，并且随后`释放`所有`活动的线程`,`EventLoopGroup.shutdownGracefully()`,`Future`将在关闭完成时接收到通知
	你需要`阻塞等待`直到它完成，或者向所返回的Future`注册一个监听器`以在关闭完成时获得通知
```
EventLoopGroup group = new NioEventLoopGroup();  			← --  创建处理I/O 的EventLoopGroup
Bootstrap bootstrap = new Bootstrap();　 					← --  创建一个Bootstrap类的实例并配置它
bootstrap.group(group)
　　.channel(NioSocketChannel.class);
...
Future<?> future = group.shutdownGracefully();　 			← --  shutdownGracefully()方法将释放所有的资源，并且关闭所有的当前正在使用中的Channel
// block until the group has shutdown
future.syncUninterruptibly();

```

- 也可以在`EventLoopGroup.shutdownGracefully()方法`之前，显式地在所有活动的Channel上调用`Channel.close()`方法,
  记得关闭EventLoopGroup本身。

# 5.ChannelHandler
Netty的ChannelPipeline和ChannelHandler机制类似于Servlet和Filter过滤器，
这类拦截器实际上是职责链模式的一种变形，主要是为了方便事件的拦截和用户业务逻辑的定制。

接收并响应事件通知,数据处理逻辑,充当了所有处理入站和出站数据的应用程序逻辑的容器。
由网络事件触发的

Netty以适配器类的形式提供了大量默认的ChannelHandler实现,ChannelPipeline中的每个ChannelHandler将负责把事件转发到链中的下一个ChannelHandler

应用程序会利用一个ChannelHandler来接收解码消息

在ChannelHandler`被添加`到ChannelPipeline中或者被从ChannelPipeline中`移除`时会调用这些操作。
这些方法中的每一个都接受一个`ChannelHandlerContext`参数。

- handlerAdded	
	当把ChannelHandler添加到ChannelPipeline中时被调用
- handlerRemoved
	当从ChannelPipeline中移除ChannelHandler时被调用
- exceptionCaught
	当处理过程中在ChannelPipeline中有错误产生时被调用

 
 
1. 系统编解码框架——ByteToMessageCodec；
2. 通用基于长度的半包解码器——LengthFieldBasedFrameDecoder；
3. 码流日志打印Handler——LoggingHandler；
4. SSL安全认证Handler——SslHandler；
5. 链路空闲检测Handler——IdleStateHandler；
6. 流量整形Handler——ChannelTrafficShapingHandler；
7. Base64编解码——Base64Decoder和Base64Encoder。

I/O事件 称为Inbound事件，
由用户线程或者代码发起的I/O操作被称为outbound事件，
事实上inbound和outbound是Netty自身根据`事件在pipeline中的流向`抽象出来的术语，在其他NIO框架中并没有这个概念。
Pipeline负责将I/O事件通过TailHandler进行调度和传播，最终调用Unsafe的I/O方法进行I/O操作,
例如：connect ，pipeline直接调用TailHandler的connect方法，最终会调用到HeadHandler的connect方法,
HeadHandler调用Unsafe的connect方法发起真正的连接，pipeline仅仅负责事件的调度。

负责对I/O事件或者I/O操作进行拦截和处理，它可以`选择性`地拦截和处理自己感兴趣的事件，也可以`透传`和`终止`事件的传递。

基于ChannelHandler接口，用户可以方便地进行业务逻辑定制，例如打印日志、统一封装异常信息、性能统计和消息编解码等。

ChannelHandler支持注解:
- ◎ Sharable：多个ChannelPipeline共用同一个ChannelHandler；
- ◎ Skip：被Skip注解的方法不会被调用，直接被忽略。



## 5.1 ChannelInboundHandler
定义响应入站事件的方法,将会经常实现的子接口 ,接收入站事件和数据,
当你要给连接的客户端发送响应时，也可以从ChannelInboundHandler冲刷数据。
应用程序的业务逻辑通常驻留在一个或者多个ChannelInboundHandler中



`@Sharable` 标示一个ChannelHandler可以被多个Channel安全地共享
1. SimpleChannelInboundHandler
```
channelRead0()
```
2. ChannelInboundHandlerAdapter　
ChannelInboundHandler的默认实现
```
channelRead()				——对于每个传入的消息都要调用；
channelReadComplete()		——通知ChannelInboundHandler最后一次对channel-Read()的调用是当前批量读取中的最后一条消息；
exceptionCaught()			——在读取操作期间，有异常抛出时会调用。
							
```
```
write()					#异步
channelRead()			#方法返回后可能仍然没有完成,在这个时间点上不会释放消息
channelReadComplete()	#当writeAndFlush()方法被调用时被释放	 
						ctx.writeAndFlush(Unpooled.EMPTY_BUFFER).addListener(ChannelFutureListener.CLOSE); 

```

抽象类SimpleChannelInboundHandler：
SimpleChannelInboundHandler<T>，其中T是你要处理的消息的Java类型

 
|方法						|描　　述|
|--|--|
|channelRegistered				|当Channel已经注册到它的EventLoop并且能够处理I/O时被调用
|channelUnregistered				|当Channel从它的EventLoop注销并且无法处理任何I/O时被调用
|channelActive					|当Channel处于活动状态时被调用；Channel已经连接/绑定并且已经就绪
|channelInactive					|当Channel离开活动状态并且不再连接它的远程节点时被调用
|channelReadComplete 			|当Channel上的一个读操作完成时被调用 
|channelRead						|当从Channel读取数据时被调用 ， 负责`显式地释放与池化的ByteBuf实例`相关的内存 ReferenceCountUtil.release(msg);　 
|ChannelWritability - Changed	|当Channel的可写状态发生改变时被调用。用户可以确保写操作不会完成得太快（以避免发生OutOfMemoryError）或者可以在Channel变为再次可写时恢复写入。可以通过调用Channel的isWritable()方法来检测Channel的可写性。与可写性相关的阈值可以通过Channel.config(). setWriteHighWaterMark()和Channel.config().setWriteLowWater- Mark()方法来设置
|userEventTriggered				|当ChannelnboundHandler.fireUserEventTriggered()方法被调用时被调用，因为一个POJO被传经了ChannelPipeline

channelRead  实现 ChannelInboundHandlerAdapter  重写  channelRead 显式地释放内存，
 ```
 ReferenceCountUtil.release(msg); //显示释放 ，它不会通过调用ChannelHandlerContext.fireChannelRead()方法将入站消息转发给下一个ChannelInboundHandler
 
 ```
SimpleDiscardHandler 可不用显式地释放内存，




## 5.2 ChannelOutboundHandler
处理出站数据并且允许拦截所有的操作。
方法将被Channel、ChannelPipeline以及ChannelHandlerContext调用。
可按需`推迟`操作/事件,例如，如果到远程节点的写入被暂停了，那么你可以推迟冲刷操作并在稍后继续。

|类　　型|描　　述|
|--|--|
|bind(ChannelHandlerContext,SocketAddress,ChannelPromise)|当请求将Channel绑定到本地地址时被调用
|connect(ChannelHandlerContext,SocketAddress,SocketAddress,ChannelPromise)|当请求将Channel连接到远程节点时被调用
|disconnect(ChannelHandlerContext,ChannelPromise)|当请求将Channel从远程节点断开时被调用
|close(ChannelHandlerContext,ChannelPromise)|当请求关闭Channel时被调用
|deregister(ChannelHandlerContext,ChannelPromise)|当请求将Channel从它的EventLoop注销时被调用
|read(ChannelHandlerContext)|当请求从Channel读取更多的数据时被调用
|flush(ChannelHandlerContext)|当请求通过Channel将入队数据冲刷到远程节点时被调用
|write(ChannelHandlerContext,Object,ChannelPromise)|当请求通过Channel将数据写到远程节点时被调用


如果你处理了write()操作并`丢弃了一个消息`，那么你也应该负责`释放`它
```
	@Override
　　public void write(ChannelHandlerContext ctx, Object msg, ChannelPromise promise) {
　　　　ReferenceCountUtil.release(msg);　  ← -- 通过使用ReferenceCountUtil.realse(...)方法释放资源
　　　　promise.setSuccess();　  			← -- 通知ChannelPromise数据已经被处理了
　　}
```
`不仅要释放资源`，还要`通知ChannelPromise`。否则可能会出现Channel-FutureListener`收不到`某个消息已经被处理了的`通知`的情况。

总之，如果一个消息被消费或者丢弃了，并且`没有传递`给ChannelPipeline中的`下一个ChannelOutboundHandler`，
那么用户就有责任调用`ReferenceCountUtil.release()`。
如果`消息`到达了实际的`传输层`，那么当它被写入时或者Channel关闭时，都`将被`自动`释放`。

## 5.3.简化了编写ChannelHandler

使用ChannelInboundHandlerAdapter和ChannelOutboundHandlerAdapter类作为自己的ChannelHandler的起始点
 
![继承](/static/开发/JAVA/imgs/ChannelHander.png)

ChannelHandlerAdapter 实用方法isSharable()。如果其对应的实现`被标注为Sharable`，那么这个方法将返回true，
表示它可以被添加到`多个ChannelPipeline`中
方法体调用了其相关联的ChannelHandlerContext上的等效方法，从而将事件转发到了ChannelPipeline中的下一个ChannelHandler中。


# 6. ChannelPipeline
ChannelPipeline为ChannelHandler链提供了容器,并定义了用于在该链上传播入站和出站事件流的API。
当Channel被创建时，它会被自动地分配到它专属的ChannelPipeline。

负责ChannelHandler的管理和事件拦截与调度。
ChannelPipeline支持运行`态动态的添加或者删除ChannelHandler`，在某些场景下这个特性非常实用。

ChannelHandler安装到ChannelPipeline中的过程:
```
1. 一个ChannelInitializer的实现被注册到了ServerBootstrap中;
2. 当ChannelInitializer.initChannel()方法被调用时,ChannelInitializer将在ChannelPipeline中安装一组自定义的ChannelHandler;
3. ChannelInitializer将它自己从ChannelPipeline中移除。

```

ChannelPipeline和ChannelHandler之间的共生关系:
ChannelHandler是专为支持广泛的用途而设计的，可以将它看作是处理往来`ChannelPipeline事件（包括数据）`的任何代码的通用容器;

Netty应用程序中入站和出站数据流之间的区别。从一个客户端应用程序的角度来看，如果事件的运动方向是从客户端到服务器端，
那么我们称这些事件为出站的，反之则称为入站的。

数据流向：
入站和出站ChannelHandler可以被安装到同一个ChannelPipeline中,



1. 底层的SocketChannel read（）方法读取ByteBuf，触发ChannelRead事件，
	由I/O线程NioEventLoop调用ChannelPipeline的fireChannelRead（Object msg）方法，将消息（ByteBuf）传输到ChannelPipeline中。
2. 消息依次被HeadHandler、ChannelHandler1、ChannelHandler2……TailHandler拦截和处理，在这个过程中，
	任何ChannelHandler都可以中断当前的流程，结束消息的传递。
3. 调用ChannelHandlerContext的write方法发送消息，消息从TailHandler开始，
	途经ChannelHandlerN……ChannelHandler1、HeadHandler，最终被添加到消息发送缓冲区中等待刷新和发送，在此过程中也可以中断消息的传递，
	例如当编码失败时，就需要中断流程，构造异常的Future返回。

Netty中的事件分为inbound事件和outbound事件。inbound事件通常由I/O线程触发，例如TCP链路建立事件、链路关闭事件、读事件、异常通知事件等:

触发inbound事件的方法如下:
1. ChannelHandlerContext.fireChannelRegistered（）：Channel注册事件；
2. ChannelHandlerContext.fireChannelActive（）：TCP链路建立成功，Channel激活事件；
3. ChannelHandlerContext.fireChannelRead（Object）：读事件；
4. ChannelHandlerContext.fireChannelReadComplete（）：读操作完成通知事件；
5. ChannelHandlerContext.fireExceptionCaught（Throwable）：异常通知事件；
6. ChannelHandlerContext.fireUserEventTriggered（Object）：用户自定义事件；
7. ChannelHandlerContext.fireChannelWritabilityChanged（）：Channel的可写状态变化通知事件；
8. ChannelHandlerContext.fireChannelInactive（）：TCP连接关闭，链路不可用通知事件。


Outbound事件通常是由用户主动发起的网络I/O操作，例如用户发起的连接操作、绑定操作、消息发送等操作
触发outbound事件的方法如下：
1. ChannelHandlerContext.bind（SocketAddress，ChannelPromise）：绑定本地地址事件；
2. ChannelHandlerContext.connect（SocketAddress，SocketAddress，ChannelPromise）：连接服务端事件；
3. ChannelHandlerContext.write（Object，ChannelPromise）：发送事件；
4. ChannelHandlerContext.flush（）：刷新事件；
5. ChannelHandlerContext.read（）： 读事件；
6. ChannelHandlerContext.disconnect（ChannelPromise）：断开连接事件；
7. ChannelHandlerContext.close（ChannelPromise）：关闭当前Channel事件。

入站：
如果一个消息或者任何其他的入站事件被读取，
那么它会从`ChannelPipeline的头部`开始流动，
并被传递给`第一个ChannelInboundHandler`。
这个ChannelHandler不一定会实际地修改数据，具体取决于它的具体功能，
在这之后，数据将会被传递给链中的`下一个ChannelInboundHandler`。
最终，数据将会到达`ChannelPipeline的尾端`，届时，所有处理就都结束了。

出站：
数据将从ChannelOutboundHandler链的尾端开始流动，直到它到达链的头部为止。
在这之后，出站数据将会到达网络传输层，这里显示为Socket。通常情况下，这将触发一个写操作。


两种发送消息的方式
可以直接写到`Channel`中，也可以写到ChannelHandler相关联的`ChannelHandlerContext对象`,
前一种方式将会导致消息从ChannelPipeline的尾端开始流动，而后者将导致消息从ChannelPipeline中的下一个ChannelHandler开始流动。


`ChannelHandlerContext`使得ChannelHandler能够和它的ChannelPipeline以及其他的ChannelHandler`交互` 

通过调用ChannelPipeline.addXXX()方法将入站处理器（ChannelInboundHandler）和出站处理器（ChannelOutboundHandler）混合添加到ChannelPipeline之后，
每一个ChannelHandler从头部到尾端的顺序位置正如同我们方才所定义它们的一样

在ChannelPipeline传播事件时，它会测试ChannelPipeline中的下一个ChannelHandler的`类型`是否和`事件的运动方向`相匹配。
如果不匹配，ChannelPipeline将跳过该ChannelHandler并前进到下一个，直到它找到和该事件所期望的方向相匹配的为止 ,(ChannelHandler 可同时实现In 和Out接口)


ChannelHandler可以通过添加、删除或者替换 来实时地`修改ChannelPipeline的布局`

ChannelPipeline中的每一个ChannelHandler都是通过它的	`EventLoop（I/O线程）来处理传递给它的事件`的。所以至关重要的是`不要阻塞这个线程`
但是 使用阻塞API的遗留代码进行交互 ChannelPipeline 接受一个EventExecutorGroup的add()方法
如果一个事件被传递给一个自定义的EventExecutor- Group，它将被包含在这个EventExecutorGroup中的某个EventExecutor所处理，从而被从该Channel本身的EventLoop中移除。对于这种用例，
Netty提供了一个叫`DefaultEventExecutorGroup`的默认实现。

## 6.1 触发事件
ChannelPipeline的入站操作

|方 法 名 称|描　　述|
|--|--|
|fireChannelRegistered|调用ChannelPipeline中下一个ChannelInboundHandler的channelRegistered(ChannelHandlerContext)方法|
|fireChannelUnregistered|调用ChannelPipeline中下一个ChannelInboundHandler的channelUnregistered(ChannelHandlerContext)方法|
|fireChannelActive|调用ChannelPipeline中下一个ChannelInboundHandler的channelActive(ChannelHandlerContext)方法|
|fireChannelInactive|调用ChannelPipeline中下一个ChannelInboundHandler的channelInactive(ChannelHandlerContext)方法|
|fireExceptionCaught|调用ChannelPipeline中下一个ChannelInboundHandler的exceptionCaught(ChannelHandlerContext, Throwable)方法|
|fireUserEventTriggered|调用ChannelPipeline中下一个ChannelInboundHandler的userEventTriggered(ChannelHandlerContext, Object)方法|
|fireChannelRead|调用ChannelPipeline中下一个ChannelInboundHandler的channelRead(ChannelHandlerContext, Object msg)方法|
|fireChannelReadComplete|调用ChannelPipeline中下一个ChannelInboundHandler的channelReadComplete(ChannelHandlerContext)方法|
|fireChannelWritabilityChanged|调用ChannelPipeline中下一个ChannelInboundHandler的channelWritabilityChanged(ChannelHandlerContext)方法|


ChannelPipeline的出站操作
方 法 名 称|描　　述|
|--|--|
|bind|将Channel绑定到一个本地地址，这将调用ChannelPipeline中的下一个ChannelOutboundHandler的bind(ChannelHandlerContext, Socket- Address, ChannelPromise)方法|
|connect|将Channel连接到一个远程地址，这将调用ChannelPipeline中的下一个ChannelOutboundHandler的connect(ChannelHandlerContext, Socket- Address, hannelPromise)方法|
|disconnect|将Channel断开连接。这将调用ChannelPipeline中的下一个ChannelOutbound- Handler的disconnect(ChannelHandlerContext, Channel Promise)方法|
|close|将Channel关闭。这将调用ChannelPipeline中的下一个ChannelOutbound- Handler的close(ChannelHandlerContext, ChannelPromise)方法|
|deregister|将Channel从它先前所分配的EventExecutor（即EventLoop）中注销。这将调用ChannelPipeline中的下一个ChannelOutboundHandler的deregister (ChannelHandlerContext, ChannelPromise)方法|
|flush|冲刷Channel所有挂起的写入。这将调用ChannelPipeline中的下一个Channel- OutboundHandler的flush(ChannelHandlerContext)方法|
|write|将消息写入Channel。这将调用ChannelPipeline中的下一个Channel- OutboundHandler的write(ChannelHandlerContext, Object msg, Channel- Promise)方法。注意：这并不会将消息写入底层的Socket，而只会将它放入队列中。要将它写入Socket，需要调用flush()或者writeAndFlush()方法|
|writeAndFlush|这是一个先调用write()方法再接着调用flush()方法的便利方法|
|read|请求从Channel中读取更多的数据。这将调用ChannelPipeline中的下一个ChannelOutboundHandler的read(ChannelHandlerContext)方法|


## 6.2. ChannelHandlerContext
每当有ChannelHandler添加到ChannelPipeline中时，都会创建ChannelHandlerContext。
ChannelHandlerContext的主要功能是管理它所关联的ChannelHandler和在同一个ChannelPipeline中的其他ChannelHandler之间的交互。
ChannelHandlerContext的一些方法也存在于Channel和ChannelPipeline本身上 
不同的是：
前者从当前所关联的ChannelHandler开始，并且只会传播给位于该ChannelPipeline中的下一个能够处理该事件的ChannelHandler
后者将沿着整个ChannelPipeline进行传播，

- ChannelHandlerContext和ChannelHandler之间的关联（绑定）是永远不会改变的，所以缓存对它的引用是安全的；
- 如同我们在本节开头所解释的一样，相对于其他类的同名方法，ChannelHandlerContext的方法将产生`更短的事件流`，
  应该尽可能地利用这个特性来获得最大的性能。

![ChannelHandler关系图](/static/开发/JAVA/imgs/ChannelHandler关系图.png)

```
ChannelHandlerContext ctx = ..; 
Channel channel = ctx.channel();   						 ← --  获取到与ChannelHandlerContext相关联的Channel 的引用
channel.write(Unpooled.copiedBuffer("Netty in Action",　 ← --  通过Channel 写入缓冲区
　　CharsetUtil.UTF_8));


ChannelHandlerContext ctx = ..;
ChannelPipeline pipeline = ctx.pipeline();   				← --  获取到与ChannelHandlerContext相关联的ChannelPipeline 的引用
pipeline.write(Unpooled.copiedBuffer("Netty in Action",　  ← --  通过ChannelPipeline写入缓冲区
　　CharsetUtil.UTF_8));

```

`事件流是一样`的。重要的是要注意到，虽然被调用的Channel或ChannelPipeline上的write()方法将一直传播事件通过整个ChannelPipeline，
但是在ChannelHandler的级别上，事件从一个ChannelHandler到下一个ChannelHandler的移动是由ChannelHandlerContext上的调用完成的

![事件传递](/static/开发/JAVA/imgs/Event.png)


```
ChannelHandlerContext ctx = ..;   ← --  获取到ChannelHandlerContext的引用
ctx.write(Unpooled.copiedBuffer("Netty in Action", CharsetUtil.UTF_8));
```
![事件传递2](/static/开发/JAVA/imgs/Event2.png) 

```
//代码1
public class WriteHandler extends ChannelHandlerAdapter {
　　private ChannelHandlerContext ctx;
　　@Override
　　public void handlerAdded(ChannelHandlerContext ctx) {
　　　　this.ctx = ctx;   ← --  存储到ChannelHandlerContext的引用以供稍后使用
　　}
　　public void send(String msg) {　 ← --  使用之前存储的到ChannelHandlerContext的引用来发送消息
　　　　ctx.writeAndFlush(msg);
　　}
}

//代码2  正确实现
@Sharable 
public class SharableHandler extends ChannelInboundHandlerAdapter {  ← --  使用注解@Sharable标注
　　@Override
　　public void channelRead(ChannelHandlerContext ctx, Object msg) {
　　　　System.out.println("Channel read message: " + msg);
　　　　ctx.fireChannelRead(msg);　  ← --  记录方法调用，并转发给下一个ChannelHandler
　　}
}


//代码3
@Sharable  ← --  使用注解@Sharable标注
public class UnsharableHandler extends ChannelInboundHandlerAdapter {
　　private int count;
　　@Override
　　public void channelRead(ChannelHandlerContext ctx, Object msg) {
　　　　count++;　 ← --  将count 字段的值加1
　　　　System.out.println("channelRead(...) called the "
　　　　　　+ count + " time");　  ← --  记录方法调用，并转发给下一个ChannelHandler
　　　　ctx.fireChannelRead(msg);
　　}
}

```

一个ChannelHandler可以·`从属于`多个ChannelPipeline，所以它也可以绑定到多个ChannelHandlerContext实例
必须要使用@Sharable注解标注,否则，试图将它添加到多个ChannelPipeline时将会触发异常

代码3它拥有状态 将这个类的一个`实例`添加到ChannelPipeline将极有可能在它被多个并发的Channel访问时导致问题
在多个ChannelPipeline中安装同一个ChannelHandler的一个常见的原因是用于`收集跨越多个Channel的统计信息`


`只应该在确定了你的ChannelHandler是线程安全的时才使用@Sharable注解。`


## 6.3 异常处理
1. 入站异常
入站事件的过程中有异常被抛出，那么它将从它在ChannelInboundHandler里被触发的那一点开始流经ChannelPipeline。
```
	@Override
　　public void exceptionCaught(ChannelHandlerContext ctx,
　　　　Throwable cause) {
　　　　cause.printStackTrace();
　　　　ctx.close();
　　}
```

异常将会继续按照入站方向流动（就像所有的入站事件一样），所以实现了`exceptionCaught`逻辑的ChannelInboundHandler通常位于ChannelPipeline的最后。这确保了所有的入站异常都总是会被处理
如果异常到达了ChannelPipeline的尾端，它将会被记录为`未被处理`；

2. 出站异常
用于处理出站操作中的正常完成以及异常的选项，都基于以下的`通知机制`

出站操作都将返回一个`ChannelFuture`。注册到ChannelFuture的`ChannelFutureListener`将在操作完成时被通知该操作是成功了还是出错了。
几乎所有的ChannelOutboundHandler上的方法都会传入一个`ChannelPromise`的实例

```
ChannelFuture future = channel.write(someMessage);
future.addListener(new ChannelFutureListener() {
　　@Override
　　public void operationComplete(ChannelFuture f) {
　　　　if (!f.isSuccess()) {
　　　　　　f.cause().printStackTrace();
　　　　　　f.channel().close();
　　　　}
　　}
});


public class OutboundExceptionHandler extends ChannelOutboundHandlerAdapter {
　　@Override
　　public void write(ChannelHandlerContext ctx, Object msg, ChannelPromise promise) {
　　　　promise.addListener(new ChannelFutureListener() {
　　　　　　@Override
　　　　　　public void operationComplete(ChannelFuture f) {
　　　　　　　　if (!f.isSuccess()) {
　　　　　　　　　　f.cause().printStackTrace();
　　　　　　　　　　f.channel().close();
　　　　　　　　}
　　　　　　}
　　　　});
　　}
}
```

通过调用ChannelPromise上的setSuccess()和setFailure()方法，
可以使一个操作的状态在ChannelHandler的方法返回给其调用者时便·`即刻`被`感知`到。


如果你的ChannelOutboundHandler本身抛出了异常会发生什么呢？在这种情况下，Netty本身会通知任何已经注册到对应ChannelPromise的监听器。

# 7.  编码器和解码器
入站消息会被解码,从字节转换为另一种格式
出站消息发生相反方向的转换：它将从它的当前格式被编码为字节,
Netty为编码器和解码器提供了不同类型的抽象类。应用程序可能使用了一种中间格式，而不需要立即将消息转换成字节。

类似于ByteToMessageDecoder或MessageToByte-Encoder
对于特殊的类型，你可能会发现类似于ProtobufEncoder和ProtobufDecoder这样的名称m,预置的用来支持Google的Protocol Buffers

由Netty提供的编码器/解码器适配器类都实现了ChannelOutboundHandler或者ChannelInboundHandler接口

入站数据:
channelRead方法/事件已经被重写了。对于每个从入站Channel读取的消息，这个方法都将会被调用。
随后，它将调用由预置解码器所提供的`decode()`方法，并将已解码的字节转发给ChannelPipeline中的`下一个ChannelInboundHandler`。

出站消息:
编码器将消息转换为字节，并将它们转发给下一个ChannelOutboundHandler。


果将消息看作是对于特定的应用程序具有具体含义的结构化的字节序列——它的数据。那么编码器是将消息转换为适合于传输的格式（最有可能的就是字节流）；而对应的解码器则是将网络字节流转换回应用程序的消息格式。因此，`编码器操作出站数据，而解码器处理入站数据`。

可以将多个解码器链接在一起，以实现任意复杂的转换逻辑，这也是Netty是如何支持代码的模块化以及复用的一个很好的例子。



将读取到的字节数组或者字节缓冲区解码为业务可以使用的POJO对象。
为了方便业务将ByteBuf解码成业务POJO对象，Netty提供了`ByteToMessageDecoder`抽象工具解码类

## 7.1. 解码器
- ByteToMessageDecoder
	将读取到的字节数组或者字节缓冲区解码为业务可以使用的POJO对象。
	为了方便业务将ByteBuf解码成业务POJO对象

	不可能知道远程节点是否会一次性地发送一个完整的消息，所以这个类会对入站数据进行缓冲，直到它准备好处理。
	然ByteToMessageDecoder使得可以很简单地实现这种模式，但是你可能会发现，在调用readInt()方法前`不得不验证`所输入的ByteBuf是否具有`足够的数据`有点繁琐。
	ReplayingDecoder是一个特殊的解码器，以`少量的开销`消除了这个步骤。

	引用计数需要特别的注意。对于编码器和解码器来说，其过程也是相当的简单：
	一旦消息被编码或者解码，它就会被ReferenceCountUtil.release(message)调用`自动释放`。
	如果你需要`保留引用`以便稍后使用，那么你可以调用`ReferenceCountUtil.retain(message)`方法。这将会增加该引用计数，从而防止该消息被释放。

- ToIntegerDecoder类
```java
public class ToIntegerDecoder extends ByteToMessageDecoder {   ← --  扩展ByteToMessage-Decoder 类，以将字节解码为特定的格式
　　@Override
　　public void decode(ChannelHandlerContext ctx, ByteBuf in, List<Object> out) throws Exception {　　
　　　　if (in.readableBytes() >= 4) {　  	//← -- 检查是否至少有4字节可读（一个int的字节长度）
　　　　　　out.add(in.readInt());   		//← -- 从入站ByteBuf 中读取一个int，并将其添加到解码消息的List 中
　　　　}
　　}
} 
```

- ReplayingDecoder
扩展了ByteToMessageDecoder类
`不必调用readableBytes()`方法。它通过使用一个自定义(ReplayingDecoderByteBuf)的ByteBuf实现， 包装传入的ByteBuf实现了这一点，其将在内部执行该调用

```java
//Void代表不需要状态管理
public class ToIntegerDecoder2 extends ReplayingDecoder<Void> {  // ← --  扩展Replaying-Decoder<Void>以将字节解码为消息
　　@Override
　　public void decode(ChannelHandlerContext ctx, ByteBuf in,　 	//← -- 传入的ByteBuf 是ReplayingDecoderByteBuf
　　　　List<Object> out) throws Exception {
　　　　out.add(in.readInt());　 									//← --  从入站ByteBuf 中读取一个int，并将其添加到解码消息的List 中
　　}
}
```

这里有一个简单的准则：如果使用ByteToMessageDecoder不会引入太多的复杂性，那么请使用它；否则，请使用ReplayingDecoder。

- io.netty.handler.codec.LineBasedFrameDecoder
	这个类在Netty内部也有使用，它使用了行尾控制字符（\n或者\r\n）来解析消息数据；

- io.netty.handler.codec.http.HttpObjectDecoder——一个HTTP数据的解码器。
	在io.netty.handler.codec子包下面，你将会发现更多用于特定用例的编码器和解码器实现。更多有关信息参见Netty的Javadoc。

- MessageToMessageDecoder
```java
public abstract class MessageToMessageDecoder<I>
　　extends ChannelInboundHandlerAdapter

```
MessageToMessageDecoder在ByteToMessageDecoder之后，所以称之为二次解码器。
以HTTP+XML协议栈为例，第一次解码往往是将`字节数组`解码成`HttpRequest对象`，
然后对`HttpRequest消息中的消息体字符串`进行二次解码，将`XML格式的字符串`解码为`POJO对象`，这就用到了二次解码器。

用户只需实现`void decode（ChannelHandlerContext ctx，I msg，List<Object>out）`抽象方法即可，
由于它是将一个POJO解码为另一个POJO，所以一般不会涉及到半包的处理，相对于ByteToMessageDecoder更加简单些。

I指定了decode()方法的输入参数msg的类型
示例中，我们将编写一个IntegerToStringDecoder解码器
解码的String将被添加到传出的List中，并转发给下一个ChannelInboundHandler。
```java
public class IntegerToStringDecoder extends MessageToMessageDecoder<Integer> {   			//← --  扩展了MessageToMessageDecoder<Integer>
　　@Override
　　public void decode(ChannelHandlerContext ctx, Integer msg
　　　　List<Object> out) throws Exception {
　　　　out.add(String.valueOf(msg));　 		//← -- 将Integer 消息转换为它的String 表示，并将其添加到输出的List 中
　　}
}
```

`io.netty.handler.codec.http.HttpObjectAggregator` 扩展了`MessageToMessageDecoder<HttpObject>`

- LengthFieldBasedFrameDecoder 半包的问题
Netty提供的半包解码器LineBasedFrameDecoder和DelimiterBased FrameDecoder；

如果消息是通过长度进行区分的，LengthFieldBasedFrameDecoder 都可以自动处理粘包和半包问题，
只需要传入正确的参数，即可轻松搞定”读半包”问题。

类型一：
消息的第一个字段是长度字段，后面是消息体
```
//获得消息长度和消息体
◎ lengthFieldOffset=0；
◎ lengthFieldLength=2；
◎ lengthAdjustment=0；
◎ initialBytesToStrip=0。

//只获得消息体
//解码后的字节缓冲区丢弃了长度字段，仅仅包含消息体，
//不过通过ByteBuf.readableBytes（）方法仍然能够获取到长度字段的值
◎ lengthFieldOffset=0；
◎ lengthFieldLength=2；
◎ lengthAdjustment=0；
◎ initialBytesToStrip=2。
```

类型二：
对于一些协议，长度还包含了消息头的长度，使用lengthAdjustment进行修正
```
◎ lengthFieldOffset=0；
◎ lengthFieldLength=2；
◎ lengthAdjustment=-2；
◎ initialBytesToStrip=0。
```
修正后的参数组合方式如下。由于整个消息的长度往往都大于消息体的长度，所以，lengthAdjustment为负数


类型三：
不是所有的协议都将长度字段放在消息头的首位，当标识消息长度的字段位于消息头的`中间`或者`尾部`时，
需要使用lengthFieldOffset字段进行标识，下面的参数组合给出了如何解决消息长度字段不在首位的问题
```
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+
|Hearder 1  |  Length  | Content		|
| 0xCAFF	|  0x00000C| ABCD			|
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+
```
```
◎ lengthFieldOffset=2；
◎ lengthFieldLength=3；
◎ lengthAdjustment=0；
◎ initialBytesToStrip=0。
```
由于消息头1的长度为2，所以长度字段的偏移量为2；消息长度字段Length为3，所以lengthFieldLength值为3。
由于长度字段仅仅标识消息体的长度，所以lengthAdjustment和initialBytesToStrip都为0。


类型四：
忽略长度字段以及其前面的其他消息头字段
```
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+
| HDR 1  |  Length  |  HDR2 | Content		|
| 0xCA   |  0x000C  |  0x0c | ABCD			|   
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+

解码后：
+~~~~~~~~~~~~~~~~~~~~~~~+
| HDR2  | Content		|
| 0x0c  | ABCD			|   
+~~~~~~~~~~~~~~~~~~~~~~~+


◎ lengthFieldOffset=1；		//由于HDR1的长度为1，所以长度字段的偏移量lengthFieldOffset为1；
◎ lengthFieldLength=2；		//长度字段为2个字节，所以lengthFieldLength为2
◎ lengthAdjustment=1；		//由于长度字段是消息体的长度，解码后如果携带消息头中的字段，则需要使用lengthAdjustment进行调整，
							//此处它的值为1，表示的是HDR2的长度
◎ initialBytesToStrip=3。	//缓冲区要忽略长度字段和HDR1部分，所以lengthAdjustment为3。解码后的结果为13个字节，HDR1和Length字段被忽略。
```
## 7.2. TooLongFrameException类
Netty是一个异步框架，所以需要在字节可以解码之前在`内存中缓冲`它们。
`不能`让解码器`缓冲大量的数据`以至于耗尽可用的内存,Netty提供了`TooLongFrameException`类,将由解码器在帧超出指定的大小限制时抛出,
将被ChannelHandler.exceptionCaught()方法捕获。

下面的ByteToMessageDecoder使用 TooLongFrameException来通知ChannelPipeline中的其他ChannelHandler发生了帧大小溢出的。
需要注意的是，`如果你正在使用一个可变帧大小的协议，那么这种保护措施将是尤为重要的`。
```java
public class SafeByteToMessageDecoder extends ByteToMessageDecoder {   ← --  扩展ByteToMessageDecoder以将字节解码为消息
　　private static final int MAX_FRAME_SIZE = 1024;
　　@Override
　　public void decode(ChannelHandlerContext ctx, ByteBuf in,
　　　　List<Object> out) throws Exception {
　　　　　　int readable = in.readableBytes();
　　　　　　if (readable > MAX_FRAME_SIZE) {　  ← -- 检查缓冲区中是否有超过MAX_FRAME_SIZE个字节
　　　　　　　　in.skipBytes(readable);　 ← --  跳过所有的可读字节，抛出TooLongFrame-Exception 并通知ChannelHandler
　　　　　　　　throw new TooLongFrameException("Frame too big!");
　　　　}
　　　　// do something
　　　　...
　　}
}

```

## 7.3. 编码器
编码器类只有一个方法，而解码器有两个。原因是解码器通常需要在Channel关闭之后产生最后一个消息（因此也就有了decodeLast()方法） 

ShortToByteEncoder，其接受一个Short类型的实例作为消息，将它编码为Short的原始类型值，并将它写入ByteBuf中，其将随后被转发给ChannelPipeline中的下一个ChannelOutboundHandler。每个传出的Short值都将会占用ByteBuf中的2字节。
```java
public class ShortToByteEncoder extends MessageToByteEncoder<Short> {   ← --  扩展了MessageToByteEncoder
　　@Override
　　public void encode(ChannelHandlerContext ctx, Short msg, ByteBuf out)
　　　　throws Exception {
　　　　out.writeShort(msg);　 ← --  将Short 写入ByteBuf 中
　　}
} 
```

专门化的MessageToByteEncoder，你可以基于它们实现自己的编码器
- 抽象类MessageToMessageEncoder
	于出站数据将如何从一种消息编码为另一种

负责将POJO对象编码成ByteBuf

```java
public class IntegerToStringEncoder
　　extends MessageToMessageEncoder<Integer> {   ← --  扩展了MessageToMessageEncoder
　　@Override
　　public void encode(ChannelHandlerContext ctx, Integer msg
　　　　List<Object> out) throws Exception {
　　　　out.add(String.valueOf(msg));　 ← --  将Integer 转换为String，并将其添加到List 中
　　}
}

```
- LengthFieldPrepender编码器
第一个字段为长度字段，计算当前待发送消息的二进制字节长度，将该长度添加到ByteBuf的缓冲区头中
长度写入到ByteBuf的前2个字节，编码后的消息组成为`长度字段+原消息的方式`
设置`LengthFieldPrepender`为true,消息长度将包含长度本身占用的字节数;

## 7.4. 编解码器类
编解码器类每个都将捆绑一个解码器/编码器对,这些类同时实现了ChannelInboundHandler和ChannelOutboundHandler接口
- ByteToMessageCodec
- MessageToMessageCodec
	websocket
```java
public class WebSocketConvertHandler extends
　　MessageToMessageCodec<WebSocketFrame, WebSocketConvertHandler.MyWebSocketFrame> {
　　@Override
　　protected void encode(ChannelHandlerContext ctx,    //← --  将MyWebSocketFrame 编码为指定的WebSocketFrame子类型
　　　　WebSocketConvertHandler.MyWebSocketFrame msg,
　　　　List<Object> out) throws Exception {
　　　　ByteBuf payload = msg.getData().duplicate().retain();
　　　　switch (msg.getType()) {　 						 //← --  实例化一个指定子类型的WebSocketFrame
　　　　　　case BINARY:
　　　　　　　　out.add(new BinaryWebSocketFrame(payload));
　　　　　　　　break;
　　　　　　case TEXT:
　　　　　　　　out.add(new TextWebSocketFrame(payload));
　　　　　　　　break;
　　　　　　case CLOSE:
　　　　　　　　out.add(new CloseWebSocketFrame(true, 0, payload));
　　　　　　　　break;
　　　　　　case CONTINUATION:
　　　　　　　　out.add(new ContinuationWebSocketFrame(payload));
　　　　　　　　break;
　　　　　　case PONG:
　　　　　　　　out.add(new PongWebSocketFrame(payload));
　　　　　　　　break;
　　　　　　case PING:
　　　　　　　　out.add(new PingWebSocketFrame(payload));
　　　　　　　　break;
　　　　　　default:
　　　　　　　　throw new IllegalStateException(
　　　　　　　　　　"Unsupported websocket msg " + msg);
　　　　}
　　}

　　@Override
　　protected void decode(ChannelHandlerContext ctx, WebSocketFrame msg,  ← --  将WebSocketFrame 解码为MyWebSocketFrame，并设置FrameType
　　　　List<Object> out) throws Exception {
　　　　　　ByteBuf payload = msg.content().duplicate().retain();
　　　　　　if (msg instanceof BinaryWebSocketFrame) {
　　　　　　　　out.add(new MyWebSocketFrame(
　　　　　　　　　　MyWebSocketFrame.FrameType.BINARY, payload));
　　　　　　} else
　　　　　　if (msg instanceof CloseWebSocketFrame) {
　　　　　　　　out.add(new MyWebSocketFrame (
　　　　　　　　　　MyWebSocketFrame.FrameType.CLOSE, payload));
　　　　　　} else
　　　　　　if (msg instanceof PingWebSocketFrame) {
　　　　　　　　out.add(new MyWebSocketFrame (
　　　　　　　　　　MyWebSocketFrame.FrameType.PING, payload));
　　　　　　} else
　　　　　　if (msg instanceof PongWebSocketFrame) {
　　　　　　　　out.add(new MyWebSocketFrame (
　　　　　　　　　　MyWebSocketFrame.FrameType.PONG, payload));
　　　　　　} else
　　　　　　if (msg instanceof TextWebSocketFrame) {
　　　　　　　　out.add(new MyWebSocketFrame (
　　　　　　　　　　MyWebSocketFrame.FrameType.TEXT, payload));
　　　　　　} else
　　　　　　if (msg instanceof ContinuationWebSocketFrame) {
　　　　　　　　out.add(new MyWebSocketFrame (
　　　　　　　　　　MyWebSocketFrame.FrameType.CONTINUATION, payload));
　　　　　　} else
　　　　　　{
　　　　　　　　throw new IllegalStateException(
　　　　　　　　　　"Unsupported websocket msg " + msg);
　　　　}
　　}

　　public static final class MyWebSocketFrame { ← --  声明WebSocketConvertHandler所使用的OUTBOUND_IN 类型　
　　　　public enum FrameType {　 ← -- 定义拥有被包装的有效负载的WebSocketFrame的类型　
　　　　　　BINARY,
　　　　　　CLOSE,
　　　　　　PING,
　　　　　　PONG,
　　　　　　TEXT,
　　　　　　CONTINUATION
　　　　}
　　　　private final FrameType type;
　　　　private final ByteBuf data;

　　　　public MyWebSocketFrame(FrameType type, ByteBuf data) {
　　　　　　this.type = type;
　　　　　　this.data = data;
　　　　}

　　　　public FrameType getType() {
　　　　　　return type;
　　　　}

　　　　public ByteBuf getData() {
　　　　　　return data;
　　　　}
　　}
}


```
- CombinedChannelDuplexHandler
	结合一个解码器和编码器可能会对可重用性造成影响。
	既能够避免这种惩罚，又不会牺牲将一个解码器和一个编码器作为一个单独的单元部署所带来的便利性
```java
public class CombinedChannelDuplexHandler
　　<I extends ChannelInboundHandler,
　　O extends ChannelOutboundHandler>
```
充当了ChannelInboundHandler和ChannelOutboundHandler（该类的类型参数I和O）的`容器`
这个类充当了ChannelInboundHandler和ChannelOutboundHandler（该类的类型参数I和O）的容器。通过提供分别继承了解码器类和编码器类的类型，实现一个编解码器，而又不必直接扩展抽象的编解码器类。

```java
public class ByteToCharDecoder extends ByteToMessageDecoder {   ← --  扩展了ByteToMessageDecoder
　　@Override
　　public void decode(ChannelHandlerContext ctx, ByteBuf in,
　　　　List<Object> out) throws Exception {
　　　　　　while (in.readableBytes() >= 2) {  ← --  将一个或者多个Character对象添加到传出的List 中
　　　　　　　　out.add(in.readChar());　
　　　　}
　　}
}


public class CharToByteEncoder extends
　　MessageToByteEncoder<Character> {   ← --  扩展了MessageToByteEncoder
　　@Override
　　public void encode(ChannelHandlerContext ctx, Character msg,
　　　　ByteBuf out) throws Exception {
　　　 out.writeChar(msg);　 ← -- 将Character 解码为char，并将其写入到出站ByteBuf 中
　　}
}

public class CombinedByteCharCodec extends
　　CombinedChannelDuplexHandler<ByteToCharDecoder, CharToByteEncoder> {   ← --  通过该解码器和编码器实现参数化CombinedByteCharCodec
　　public CombinedByteCharCodec() {
　　　　super(new ByteToCharDecoder(), new CharToByteEncoder());　 ← -- 将委托实例传递给父类
　　}
}


```
在某些情况下，通过这种方式结合实现相对于使用编解码器类的方式来说可能更加的简单也更加的灵活


## 7.5. HTTP
### 7.5.1. SSL
为了支持SSL/TLS，Java提供了javax.net.ssl包，它的SSLContext和SSLEngine类使得实现解密和加密相当简单直接。Netty通过一个名为SslHandler的ChannelHandler实现利用了这个API，其中SslHandler在内部使用SSLEngine来完成实际的工作。

SslHandler
```java
public class SslChannelInitializer extends ChannelInitializer<Channel>{
　　private final SslContext context; 
　　private final boolean startTls;

　　public SslChannelInitializer(SslContext context,  	 ← --  传入要使用的SslContext
　　　　boolean startTls) {　 								 ← --  如果设置为true，第一个写入的消息将不会被加密（客户端应该设置为true）
　　　　this.context = context;
　　　　this.startTls = startTls;
　　}

　　@Override
　　protected void initChannel(Channel ch) throws Exception {
　　　　SSLEngine engine = context.newEngine(ch.alloc());   //← -- 对于每个SslHandler 实例，都使用Channel 的ByteBuf-Allocator 从SslContext 获取一个新的SSLEngine
　　　　ch.pipeline().addFirst("ssl",
　　　　　　new SslHandler(engine, startTls));   			// ← -- 将SslHandler 作为第一个ChannelHandler 添加到ChannelPipeline 中 
　　}
}
```
具有一些有用的方法:
在握手阶段，两个节点将相互验证并且商定一种加密方式。你可以通过配置SslHandler来修改它的行为，或者在SSL/TLS握手一旦完成之后提供通知，握手阶段完成之后，所有的数据都将会被加密。SSL/TLS握手将会被自动执行。


一个HTTP请求/响应可能由多个数据部分组成，并且它总是以一个LastHttpContent部分作为结束
FullHttpRequest和FullHttpResponse消息是特殊的子类型，分别代表了完整的请求和响应。
```java
public class HttpPipelineInitializer extends ChannelInitializer<Channel> {
　　private final boolean client;

　　public HttpPipelineInitializer(boolean client) {
　　　　this.client = client;
　　}

　　@Override
　　protected void initChannel(Channel ch) throws Exception {
　　　　ChannelPipeline pipeline = ch.pipeline();
　　　　if (client) {  												//← --  如果是客户端，则添加HttpResponseDecoder 以处理来自服务器的响应
　　　　　　pipeline.addLast("decoder", new HttpResponseDecoder()); 
　　　　　　pipeline.addLast("encoder", new HttpRequestEncoder());　  //← --  如果是客户端，则添加HttpRequestEncoder以向服务器发送请求
　　　　} else {
　　　　　　pipeline.addLast("decoder", new HttpRequestDecoder());   //← -- 如果是服务器，则添加HttpRequestDecoder以接收来自客户端的请求
　　　　　　pipeline.addLast("encoder", new HttpResponseEncoder());  //← -- 如果是服务器，则添加HttpResponseEncoder以向客户端发送响应
　　　　}
　　}
}


```

### 7.5.2. 聚合HTTP消息
在ChannelInitializer将ChannelHandler安装到ChannelPipeline中之后，你便可以处理不同类型的HttpObject消息了,
但是由于HTTP的请求和响应可能由许多部分组成，因此你需要聚合它们以形成完整的消息。为了消除这项繁琐的任务，Netty提供了一个聚合器，它可以将多个消息部分合并为FullHttpRequest或者FullHttpResponse消息。通过这样的方式，你将总是看到完整的消息内容。
由于消息分段需要被缓冲，直到可以转发一个完整的消息给下一个ChannelInbound-Handler，所以这个操作有轻微的开销。其所带来的好处便是你`不必关心消息碎片`了。

只不过是向ChannelPipeline中添加另外一个ChannelHandler罢了
```java
public class HttpAggregatorInitializer extends ChannelInitializer<Channel> {
　　private final boolean isClient;

　　public HttpAggregatorInitializer(boolean isClient) {
　　　　this.isClient = isClient;
　　}

　　@Override
　　protected void initChannel(Channel ch) throws Exception {
　　　　ChannelPipeline pipeline = ch.pipeline();
　　　　if (isClient) {
　　　　　　pipeline.addLast("codec", new HttpClientCodec());   ← --  如果是客户端，则添加HttpClientCodec
　　　　} else {
　　　　　　pipeline.addLast("codec", new HttpServerCodec());　 ← -- 如果是服务器，则添加HttpServerCodec
　　　　}
　　　　pipeline.addLast("aggregator",
　　　　　　new HttpObjectAggregator(512 * 1024));　 ← --  将最大的消息大小为512 KB的HttpObjectAggregator 添加到ChannelPipeline
　　}
}
```

### 7.5.3. HTTP压缩
Netty为压缩和解压缩提供了ChannelHandler实现，它们同时支持`gzip`和`deflate`编码。
客户端可以通过提供以下头部信息来指示服务器它所支持的压缩格式：
```process
GET /encrypted-area HTTP/1.1
Host: www.example.com
Accept-Encoding: gzip, deflate
```
然而，需要注意的是， 服务器`没有义务压缩`它所发送的数据。
```java
public class HttpCompressionInitializer extends ChannelInitializer<Channel> {
　　private final boolean isClient;

　　public HttpCompressionInitializer(boolean isClient) {
　　　　this.isClient = isClient;
　　}

　　@Override
　　protected void initChannel(Channel ch) throws Exception {
　　　　ChannelPipeline pipeline = ch.pipeline();
　　　　if (isClient) {
　　　　　　 pipeline.addLast("codec", new HttpClientCodec());   ← --  如果是客户端，则添加HttpClientCodec
　　　　　  pipeline.addLast("decompressor", 　new HttpContentDecompressor()); ← --  如果是客户端，则添加HttpContentDecompressor 以处理来自服务器的压缩内容 
　　　　} else {
　　　　　　pipeline.addLast("codec", new HttpServerCodec());   ← --  如果是服务器，则添加HttpServerCodec
　　　　　　pipeline.addLast("compressor", new HttpContentCompressor());　 ← -- 如果是服务器，则添加HttpContentCompressor来压缩数据（如果客户端支持它）
　　　　}
　　}
}

```

### 7.5.4. 　使用HTTPS
启用HTTPS只需要将SslHandler添加到ChannelPipeline的ChannelHandler组合中。

```java
public class HttpsCodecInitializer extends ChannelInitializer<Channel> {
　　private final SslContext context;
　　private final boolean isClient;

　　 public HttpsCodecInitializer(SslContext context, boolean isClient) {
　　　　 this.context = context;
　　　　 this.isClient = isClient;
　　 }

　　@Override
　　protected void initChannel(Channel ch) throws Exception {
　　　　ChannelPipeline pipeline = ch.pipeline();
　　　　SSLEngine engine = context.newEngine(ch.alloc());
　　　　pipeline.addFirst("ssl", new SslHandler(engine));   ← --  将SslHandler 添加到ChannelPipeline 中以使用HTTPS

　　　　if (isClient) {
　　　　　　pipeline.addLast("codec", new HttpClientCodec());   ← --  如果是客户端，则添加HttpClientCodec
　　　　} else {
　　　　　　pipeline.addLast("codec", new HttpServerCodec());   ← --  如果是服务器，则添加HttpServerCodec
　　　　}
　　}
}


```

## 7.6 WebSocket
WebSocket提供了“在一个`单个的TCP连接`上提供双向的通信……结合WebSocket API……它为网页和远程服务器之间的双向通信提供了一种替代HTTP轮询的方案。”

尽管`最早的实现仅限于文本数据`，但是现在已经不是问题了；WebSocket现在可以用于传输`任意类型的数据`，很像普通的套接字。
首先通信将作为普通的HTTP协议开始，随后升级到双向的WebSocket协议。

添加对于WebSocket的支持，你需要将适当的客户端或者服务器WebSocket ChannelHandler添加到ChannelPipeline中。
这个类将处理由WebSocket定义的称为`帧的特殊消息类型`。

|帧类型|描述|
|--|--|
|inaryWebSocketFrame|数据帧：二进制数据|
|TextWebSocketFrame|数据帧：文本数据|
|ContinuationWebSocketFrame|
|数据帧：属于上一个BinaryWebSocketFrame或者TextWeb- SocketFrame的文本的或者二进制数据|
|CloseWebSocketFrame|控制帧：一个CLOSE请求、关闭的状态码以及关闭的原因|
|PingWebSocketFrame|控制帧：请求一个PongWebSocketFrame|
|PongWebSocketFrame|控制帧：对PingWebSocketFrame请求的响应|

使用WebSocketServerProtocolHandler的简单示例，这个类处理协议升级握手，以及3种控制帧——Close、Ping和Pong。Text和Binary数据帧将会被传递给下一个（由你实现的）ChannelHandler进行处理。
```java
public class WebSocketServerInitializer extends ChannelInitializer<Channel>{
　　@Override
　　protected void initChannel(Channel ch) throws Exception {
　　　　ch.pipeline().addLast(
　　　　　　new HttpServerCodec(),
　　　　　　new HttpObjectAggregator(65536),   ← --  为握手提供聚合的HttpRequest
　　　　　  new WebSocketServerProtocolHandler("/websocket"), ← --  如果被请求的端点是"/websocket"，则处理该升级握手　
　　　　　　new TextFrameHandler(),　 ← --  TextFrameHandler 处理TextWebSocketFrame
　　　　　  new BinaryFrameHandler(),　← -- BinaryFrameHandler 处理BinaryWebSocketFrame　
　　　　　  new ContinuationFrameHandler());　← -- ContinuationFrameHandler 处理ContinuationWebSocketFrame　 
　　}

　　public static final class TextFrameHandler extends
　　　　SimpleChannelInboundHandler<TextWebSocketFrame> {
　　　　@Override
　　　　public void channelRead0(ChannelHandlerContext ctx,
　　　　　　TextWebSocketFrame msg) throws Exception {
　　　　　　// Handle text frame
　　　　}
　　}

　　public static final class BinaryFrameHandler extends
　　　　SimpleChannelInboundHandler<BinaryWebSocketFrame> {
　　　　@Override
　　　　public void channelRead0(ChannelHandlerContext ctx,
　　　　　　BinaryWebSocketFrame msg) throws Exception {
　　　　　　// Handle binary frame
　　　　}
　　}

　　public static final class ContinuationFrameHandler extends
　　　　SimpleChannelInboundHandler<ContinuationWebSocketFrame> {
　　　　@Override
　　　　public void channelRead0(ChannelHandlerContext ctx,
　　　　　　ContinuationWebSocketFrame msg) throws Exception {
　　　　　　// Handle continuation frame
　　　　}
　　}
}

```

## 7.7. 空闲的连接和超时
检测空闲连接以及超时对于及时释放资源来说是至关重要的
几个ChannelHandler实现

|名　　称|描　　述|
|--|--|
|IdleStateHandler|当连接空闲时间太长时，将会触发一个IdleStateEvent事件。然后，你可以通过在你的ChannelInboundHandler中重写userEventTriggered()方法来处理该IdleStateEvent事件|
|ReadTimeoutHandler|如果在指定的时间间隔内没有收到任何的入站数据，则抛出一个ReadTimeoutException并关闭对应的Channel。可以通过重写你的ChannelHandler中的exceptionCaught()方法来检测该Read- TimeoutException|
|WriteTimeoutHandler|如果在指定的时间间隔内没有任何出站数据写入，则抛出一个Write-TimeoutException并关闭对应的Channel。可以通过重写你的ChannelHandler的exceptionCaught()方法检测该WriteTimeout- Exception|


使用IdleStateHandler来测试远程节点是否仍然还活着，并且在它失活时通过关闭连接来释放资源。

```java

public class IdleStateHandlerInitializer extends ChannelInitializer<Channel>
　　{
　　@Override
　　protected void initChannel(Channel ch) throws Exception {
　　　　ChannelPipeline pipeline = ch.pipeline();
　　　　pipeline.addLast(
　　　　　　new IdleStateHandler(0, 0, 60, TimeUnit.SECONDS));   ← --  ❶IdleStateHandler 将在被触发时发送一个IdleStateEvent 事件
　　　　pipeline.addLast(new HeartbeatHandler());　 ← --  将一个HeartbeatHandler添加到ChannelPipeline中
　　}

　　public static final class HeartbeatHandler　  ← -- 实现userEven t-Triggered()方法以发送心跳消息
　　　　extends ChannelInboundHandlerAdapter {
　　　private static final ByteBuf HEARTBEAT_SEQUENCE =   ← -- 发送到远程节点的心跳消息 
　　　　　　Unpooled.unreleasableBuffer(Unpooled.copiedBuffer(
　　　　　　"HEARTBEAT", CharsetUtil.ISO_8859_1));

　　　　@Override
　　　　public void userEventTriggered(ChannelHandlerContext ctx,
　　　　　　Object evt) throws Exception {
　　　　　　if (evt instanceof IdleStateEvent) {   ← -- ❷发送心跳消息，并在发送失败时关闭该连接 
　　　　　　　　ctx.writeAndFlush(HEARTBEAT_SEQUENCE.duplicate())
　　　　　　　　　　.addListener(
　　　　　　　　　　　　ChannelFutureListener.CLOSE_ON_FAILURE);
　　　　　　} else {
　　　　　　　　super.userEventTriggered(ctx, evt);  ← -- 不是IdleStateEvent事件，所以将它传递给下一个Channel-InboundHandler 
　　　　　　}
　　　　}
　　}
}
```

如果连接超过60秒没有接收或者发送任何的数据，那么IdleStateHandler❶将会使用一个IdleStateEvent事件来调用fireUserEventTriggered()方法。HeartbeatHandler实现了userEventTriggered()方法，如果这个方法检测到IdleStateEvent事件，它将会发送心跳消息，并且添加一个将在发送操作失败时关闭该连接的ChannelFutureListener❷。


## 7.8 解码基于分隔符的协议和基于长度的协议
### 7.8.1 分隔符的协议
基于分隔符的（delimited）消息协议使用`定义的字符来标记`的消息或者消息段（通常被称为帧）的开头或者结尾。
由RFC文档正式定义的许多协议（如SMTP、POP3、IMAP以及Telnet[5]）都是这样的。

|名　　称|描　　述|
|--|--|
|DelimiterBasedFrameDecoder|使用任何由用户提供的分隔符来提取帧的通用解码器|
|LineBasedFrameDecoder|提取由行尾符（\n或者\r\n）分隔的帧的解码器。这个解码器比DelimiterBasedFrameDecoder更快|

```java
public class LineBasedHandlerInitializer extends ChannelInitializer<Channel>
　　{
　　@Override
　　protected void initChannel(Channel ch) throws Exception {
　　　　ChannelPipeline pipeline = ch.pipeline();
　　　　pipeline.addLast(new LineBasedFrameDecoder(64 * 1024));   //← --  该LineBasedFrame-Decoder 将提取的帧转发给下一个Channel-InboundHandler
　　　　pipeline.addLast(new FrameHandler());　  ← --  添加FrameHandler以接收帧
　　}

　　public static final class FrameHandler
　　　　extends SimpleChannelInboundHandler<ByteBuf> {
　　　　@Override
　　　　public void channelRead0(ChannelHandlerContext ctx,   //← -- 传入了单个帧的内容 
　　　　　　 ByteBuf msg) throws Exception {
　　　　　　 // Do something with the data extracted from the frame
　　　　}
　　}
}

```
- 传入数据流是一系列的帧，每个帧都由换行符（\n）分隔；
- 每个帧都由一系列的元素组成，每个元素都由单个空格字符分隔；
- 一个帧的内容代表一个命令，定义为一个命令名称后跟着数目可变的参数。

我们用于这个协议的自定义解码器将定义以下类：

- Cmd——将帧（命令）的内容存储在ByteBuf中，一个ByteBuf用于名称，另一个用于参数；
- CmdDecoder——从被重写了的decode()方法中获取一行字符串，并从它的内容构建一个Cmd的实例；
- CmdHandler ——从CmdDecoder获取解码的Cmd对象，并对它进行一些处理；
- CmdHandlerInitializer ——为了简便起见，我们将会把前面的这些类定义为专门的ChannelInitializer的嵌套类，其将会把这些ChannelInboundHandler安装到ChannelPipeline中。

```java
public class CmdHandlerInitializer extends ChannelInitializer<Channel> {
　　final byte SPACE = (byte)' ';
　　@Override
　　protected void initChannel(Channel ch) throws Exception {
　　　　ChannelPipeline pipeline = ch.pipeline();
　　　　pipeline.addLast(new CmdDecoder(64 * 1024));  ← --   添加CmdDecoder 以提取Cmd 对象，并将它转发给下一个ChannelInboundHandler
　　　　pipeline.addLast(new CmdHandler());　 ← -- 添加CmdHandler 以接收和处理Cmd 对象
　　}

　　public static final class Cmd {　  ← -- Cmd POJO
　　　　private final ByteBuf name;
　　　　private final ByteBuf args;

　　　　public Cmd(ByteBuf name, ByteBuf args) {
　　　　　　this.name = name;
　　　　　　this.args = args;
　　　　}

　　　　public ByteBuf name() {
　　　　　　return name;
　　　　}

　　　　public ByteBuf args() {
　　　　　　return args;
　　　　}
　　}

　　public static final class CmdDecoder extends LineBasedFrameDecoder {
　　　　public CmdDecoder(int maxLength) {
　　　　　　super(maxLength);
　　　　}

　　　　@Override
　　　　protected Object decode(ChannelHandlerContext ctx, ByteBuf buffer)
　　　　　　throws Exception {
　　　　　　ByteBuf frame = (ByteBuf) super.decode(ctx, buffer);　  ← --  从ByteBuf 中提取由行尾符序列分隔的帧
　　　　　　if (frame == null) {　　
　　　　　　　　return null;　  ← --  如果输入中没有帧，则返回null　
　　　　　　}
　　　　　　int index = frame.indexOf(frame.readerIndex(),　 ← --  查找第一个空格字符的索引。前面是命令名称，接着是参数
　　　　　　　　frame.writerIndex(), SPACE);
　　　　　　return new Cmd(frame.slice(frame.readerIndex(), index),  ← -- 使用包含有命令名称和参数的切片创建新的Cmd 对象
　　　　　　　　frame.slice(index + 1, frame.writerIndex()));
　　　　}
　　}

　　public static final class CmdHandler
　　　　extends SimpleChannelInboundHandler<Cmd> {
　　　　@Override
　　　　public void channelRead0(ChannelHandlerContext ctx, Cmd msg)
　　　　　　throws Exception {
　　　　　　// Do something with the command  ← -- 处理传经ChannelPipeline的Cmd 对象　
　　　　}
　　}

```
## 7.8.2 基于长度的协议
将它的长度编码到帧的头部来定义帧，而不是使用特殊的分隔符来标记它的结束。
- FixedLengthFrameDecoder
	提取在调用构造函数时指定的定长帧
- LengthFieldBasedFrameDecoder 
	根据编码进帧头部中的长度值提取帧；该字段的偏移量以及长度在构造函数中指定

经常会遇到被编码到消息头部的帧大小不是固定值的协议。为了处理这种变长帧，你可以使用LengthFieldBasedFrameDecoder，
它将`从头部字段确定帧长`，然后从数据流中提取指定的字节数。

engthFieldBasedFrameDecoder提供了几个构造函数来支持各种各样的头部配置情况。代码清单11-10展示了如何使用其3个构造参数分别为maxFrameLength、lengthField-Offset和lengthFieldLength的构造函数。在这个场景中，帧的长度被编码到了帧起始的前8个字节中。
```java
public class LengthBasedInitializer extends ChannelInitializer<Channel> {　　
　　@Override
　　protected void initChannel(Channel ch) throws Exception {
　　　　ChannelPipeline pipeline = ch.pipeline();
　　　　pipeline.addLast(   ← --  使用LengthFieldBasedFrameDecoder 解码将帧长度编码到帧起始的前8 个字节中的消息
　　　　　　new LengthFieldBasedFrameDecoder(64 * 1024, 0, 8)); 
　　　　pipeline.addLast(new FrameHandler());　 ← --  添加FrameHandler以处理每个帧 
　　}

　　public static final class FrameHandler
　　　　extends SimpleChannelInboundHandler<ByteBuf> {
　　　　@Override
　　　　public void channelRead0(ChannelHandlerContext ctx,
　　　　　　ByteBuf msg) throws Exception {
　　　　　　// Do something with the frame  ← --  处理帧的数据
　　　　}
　　}
}

```

## 7.9 写大型数据
由于写操作是非阻塞的，所以即使没有写出所有的数据，写操作也会在完成时返回并通知Channel-Future。
当这种情况发生时，如果仍然不停地写入，就有内存耗尽的风险。
所以在写大型数据时，需要准备好处理到远程节点的连接是`慢速连接`的情况，这种情况会导致`内存释放的延迟`。

NIO的零拷贝特性，这种特性消除了将`文件的内容从文件系统移动到网络栈的复制过程`。这一切都发生在Netty的核心中，
所以应用程序所有需要做的就是`使用一个FileRegion接口`的实现，
API文档中的定义是：“`通过支持零拷贝的文件传输的Channel来发送的文件区域。`”

利用零拷贝特性来传输一个文件的内容：
```java
FileInputStream in = new FileInputStream(file);   ← -- 创建一个FileInputStream 
FileRegion region = new DefaultFileRegion(　	  ← -- 以该文件的完整长度创建一个新的DefaultFileRegion
　　in.getChannel(), 0, file.length());
channel.writeAndFlush(region).addListener(　	 ← --  发送该DefaultFile-Region，并注册一个ChannelFutureListener
　　new ChannelFutureListener() {
　　@Override
　　public void operationComplete(ChannelFuture future)
　　　　throws Exception {
　　　　if (!future.isSuccess()) {
　　　　　　Throwable cause = future.cause();　 ← --  处理失败
　　　　　　// Do something
　　　　}
　　}
});


```
在需要将数据从文件系统复制到用户内存中时，可以使用`ChunkedWriteHandler`，它支持`异步写大型数据流`，而又不会导致大量的内存消耗。


当Channel的状态变为活动的时，WriteStreamHandler将会逐块地把来自文件中的数据作为ChunkedStream写入。
数据在传输之前将会由SslHandler加密。
```java
public class ChunkedWriteHandlerInitializer
　　extends ChannelInitializer<Channel> {
　　private final File file;
　　private final SslContext sslCtx;
　　public ChunkedWriteHandlerInitializer(File file, SslContext sslCtx) {
　　　　this.file = file;
　　　　this.sslCtx = sslCtx;
　　}

　　@Override
　　protected void initChannel(Channel ch) throws Exception {
　　　　ChannelPipeline pipeline = ch.pipeline();
　　　　pipeline.addLast(new SslHandler(sslCtx.newEngine(ch.alloc());   ← --  将SslHandler 添加到ChannelPipeline 中
　　　　pipeline.addLast(new ChunkedWriteHandler());　 ← --  添加Chunked-WriteHandler以处理作为ChunkedInput传入的数据
　　　　pipeline.addLast(new WriteStreamHandler());   ← --  一旦连接建立，WriteStreamHandler就开始写文件数据　 
　　}

　　public final class WriteStreamHandler
　　　　extends ChannelInboundHandlerAdapter {

　　　　@Override
　　　　public void channelActive(ChannelHandlerContext ctx)   ← --  当连接建立时，channelActive()方法将使用ChunkedInput写文件数据
　　　　　　throws Exception {
　　　　　　super.channelActive(ctx);
　　　　　　ctx.writeAndFlush(
　　　　　　new ChunkedStream(new FileInputStream(file)));
　　　　}
　　}
}
```

## 7.10. 序列化数据
JDK提供了ObjectOutputStream和ObjectInputStream，用于通过网络对POJO的`基本数据类型`和`图`进行序列化和反序列化。
还可被用于`实现了java.io.Serializable接口`的对象,API不复杂,性能也不是非常高效的.

Netty提供的用于和JDK进行互操作的序列化类:
- CompatibleObjectDecoder
	和使用JDK序列化的非基于Netty的远程节点进行互操作的解码器
- CompatibleObjectEncoder
	和使用JDK序列化的非基于Netty的远程节点进行互操作的编码器
- ObjectDecoder
	建于JDK序列化之上的使用自定义的序列化来解码的解码器；当没有其他的外部依赖时，它提供了速度上的改进。否则其他的序列化实现更加可取
- ObjectEncoder
	构建于JDK序列化之上的使用自定义的序列化来编码的编码器；当没有其他的外部依赖时，它提供了速度上的改进。否则其他的序列化实现更加可取

###  7.10.1. JBoss Marshalling进行序列化
比JDK序列化最多快3倍，而且也更加紧凑

CompatibleMarshallingDecoder/
CompatibleMarshallingEncoder，
与只使用JDK序列化的远程节点兼容

MarshallingDecoder/
MarshallingEncoder，
适用于使用JBoss Marshalling的节点。这些类必须一起使用

使用JBoss Marshalling:
```
public class MarshallingInitializer extends ChannelInitializer<Channel> {
　　private final MarshallerProvider marshallerProvider;
　　private final UnmarshallerProvider unmarshallerProvider;

　　public MarshallingInitializer(
　　　　UnmarshallerProvider unmarshallerProvider,
　　　　MarshallerProvider marshallerProvider) {
　　　　 this.marshallerProvider = marshallerProvider;
　　　 this.unmarshallerProvider = unmarshallerProvider;
　　}

　　@Override
　　protected void initChannel(Channel channel) throws Exception {
　　　　ChannelPipeline pipeline = channel.pipeline();
　　　　 pipeline.addLast(new MarshallingDecoder(unmarshallerProvider));   ← --  添加MarshallingDecoder 以将ByteBuf 转换为POJO
　　　　pipeline.addLast(new MarshallingEncoder(marshallerProvider));　 ← -- 添加Marshalling-Encoder 以将POJO转换为ByteBuf
　　　　pipeline.addLast(new ObjectHandler());  ← -- 添加ObjectHandler，以处理普通的实现了Serializable 接口的POJO
　　}

　　public static final class ObjectHandler
　　　　extends SimpleChannelInboundHandler<Serializable> {
　　　　@Override
　　　　public void channelRead0(
　　　　　　ChannelHandlerContext channelHandlerContext,
　　　　　　Serializable serializable) throws Exception {
　　　　　　// Do something
　　　　}
　　}
}
```
###  7.10.2. Protocol Buffers序列化
Google公司开发的、现在已经开源的数据交换格式,紧凑而高效的方式对结构化的数据进行编码以及解码
- ProtobufDecoder
	使用protobuf对消息进行解码
- ProtobufEncoder
	使用protobuf对消息进行编码
- ProtobufVarint32FrameDecoder
	根据消息中的Google Protocol Buffers的“Base 128 Varints”a整型长度字段值动态地分割所接收到的ByteBuf
- ProtobufVarint32LengthFieldPrepender
	向ByteBuf前追加一个Google Protocal Buffers的“Base 128 Varints”整型的长度字段值

```
public class ProtoBufInitializer extends ChannelInitializer< Channel> {
　　private final MessageLite lite;

　　public ProtoBufInitializer(MessageLite lite) {
　　　　this.lite = lite;
　　}

　　@Override
　　protected void initChannel(Channel ch) throws Exception {
　　　　ChannelPipeline pipeline = ch.pipeline();
　　　　pipeline.addLast(new ProtobufVarint32FrameDecoder());   ← --  添加ProtobufVarint32FrameDecoder以分隔帧
　　　　pipeline.addLast(new ProtobufEncoder());　[12]  ← -- 添加ProtobufEncoder以处理消息的编码
　　　　pipeline.addLast(new ProtobufDecoder(lite));  ← -- 添加ProtobufDecoder以解码消息
　　　　pipeline.addLast(new ObjectHandler());　  ← --  添加Object-Handler 以处理解码消息
　　}

　　public static final class ObjectHandler
　　　　extends SimpleChannelInboundHandler< Object> {
　　　　　　@Override
　　　　　　public void channelRead0(ChannelHandlerContext ctx, Object msg)
　　　　　　throws Exception {
　　　　　　// Do something with the object
　　　　}
　　}
}
```
# 8. 网络
```
OIO				——阻塞传输
NIO				——异步传输
Local			——JVM内部的异步通信
Embedded		——测试你的ChannelHandler

```

JDK API Server: 
中等数量的并发客户端
并不能很好地伸缩到支撑成千上万的并发连入连接
```
public class PlainOioServer {
　　public void serve(int port) throws IOException {
　　　　final ServerSocket socket = new ServerSocket(port);  				//← --  将服务器绑定到指定端口
　　　　try {
　　　　　　for (;;) {
　　　　　　　　final Socket clientSocket = socket.accept();　 				//← --  接受连接
　　　　　　　　System.out.println(
　　　　　　　　　　"Accepted connection from " + clientSocket);
　　　　　　　　new Thread(new Runnable() {  								//← --  创建一个新的线程来处理该连接　
　　　　　　　　　 @Override
　　　　　　　　　　public void run() {
　　　　　　　　　　　　OutputStream out;
　　　　　　　　　　　　try {
　　　　　　　　　　　　　　out = clientSocket.getOutputStream();
　　　　　　　　　　　　　　out.write("Hi!\r\n".getBytes(  					//← --  将消息写给已连接的客户端
　　　　　　　　　　　　　　　　Charset.forName("UTF-8")));
　　　　　　　　　　　　　　out.flush();
　　　　　　　　　　　　　　clientSocket.close();  							//← --  关闭连接
　　　　　　　　　　　　}
　　　　　　　　　　　　catch (IOException e) {
　　　　　　　　　　　　　　e.printStackTrace();
　　　　　　　　　　　　}
　　　　　　　　　　　　finally {
　　　　　　　　　　　　　　try {
　　　　　　　　　　　　　　　　clientSocket.close();
　　　　　　　　　　　　　　}
　　　　　　　　　　　　　　catch (IOException ex) {
　　　　　　　　　　　　　　　　// ignore on close
　　　　　　　　　　　　　　}
　　　　　　　　　　　　}
　　　　　　　　　　}
　　　　　　　　}).start();　 												//← --  启动线程
　　　　　　}
　　　　}
　　　　catch (IOException e) {
　　　　　　e.printStackTrace();
　　　　}
　　}
}
```
非阻塞版本:
```
public class PlainNioServer {
　　public void serve(int port) throws IOException {
　　　　 ServerSocketChannel serverChannel = ServerSocketChannel.open();
　　　 serverChannel.configureBlocking(false);
　　　　ServerSocket ssocket = serverChannel.socket();
　　　　InetSocketAddress address = new InetSocketAddress(port);
　　　　ssocket.bind(address);　 ← --  将服务器绑定到选定的端口
　　　　 Selector selector = Selector.open();　 ← --  打开Selector来处理Channel
　　　　serverChannel.register(selector, SelectionKey.OP_ACCEPT);　 ← --  将ServerSocket注册到Selector 以接受连接
　　　　final ByteBuffer msg = ByteBuffer.wrap("Hi!\r\n".getBytes());
　　　　for (;;) {
　　　　　　try {
　　　　　　　 selector.select();　 ← --  等待需要处理的新事件；阻塞将一直持续到下一个传入事件
　　　　　　 } catch (IOException ex) {
　　　　　　　　ex.printStackTrace();
　　　　　　　　// handle exception
　　　　　　　　break;
　　　　　　}
　　　　　 Set<SelectionKey> readyKeys = selector.selectedKeys();  ← --  获取所有接收事件的Selection-Key 实例
　　　　　　Iterator<SelectionKey> iterator = readyKeys.iterator();
　　　　　　while (iterator.hasNext()) {
　　　　　　　　SelectionKey key = iterator.next();
　　　　　　　　iterator.remove();
　　　　　　　　try {
　　　　　　　　　　if (key.isAcceptable()) {　 ← --  检查事件是否是一个新的已经就绪可以被接受的连接
　　　　　　　　　　　　ServerSocketChannel server =
　　　　　　　　　　　　　　(ServerSocketChannel)key.channel();
　　　　　　　　　　SocketChannel client = server.accept();
　　　　　　　　　　client.configureBlocking(false);
　　　　　　　　　　client.register(selector, SelectionKey.OP_WRITE |  ← --  接受客户端，并将它注册到选择器
　　　　　　　　　　　　SelectionKey.OP_READ, msg.duplicate()); 
　　　　　　　　　　System.out.println(
　　　　　　　　　　　　"Accepted connection from " + client);
　　　　　　　　　　}
　　　　　　　　　　if (key.isWritable()) {　 ← --  检查套接字是否已经准备好写数据
　　　　　　　　　　　　SocketChannel client =
　　　　　　　　　　　　　　(SocketChannel)key.channel();
　　　　　　　　　　　　ByteBuffer buffer =
　　　　　　　　　　　　　　(ByteBuffer)key.attachment();
　　　　　　　　　　　　while (buffer.hasRemaining()) {
　　　　　　　　　　　　　　if (client.write(buffer) == 0) {   ← --  将数据写到已连接的客户端
　　　　　　　　　　　　　　　　break;
　　　　　　　　　　　　　　}
　　　　　　　　　　　　}
　　　　　　　　　　　　client.close();　  ← --  关闭连接
　　　　　　　　　　}
　　　　　　　　} catch (IOException ex) {
　　　　　　　　　　key.cancel();
　　　　　　　　　　try {
　　　　　　　　　　　　key.channel().close();
　　　　　　　　　　} catch (IOException cex) {
　　　　　　　　　　　　// ignore on close
　　　　　　　　　　}
}
　　　　　　}
　　　　}
　　}
}
```


通过Netty使用OIO和NIO
```
public class NettyOioServer {
　　public void server(int port) throws Exception {
　　　　final ByteBuf buf = Unpooled.unreleasableBuffer(
　　　　　　Unpooled.copiedBuffer("Hi!\r\n", Charset.forName("UTF-8")));
　　　　EventLoopGroup group = new OioEventLoopGroup();
　　　　try {
　　　　　　ServerBootstrap b = new ServerBootstrap();   ← --  创建Server-Bootstrap
　　　　　　b.group(group) 
 　　　　　　　 .channel(OioServerSocketChannel.class)  ← --  使用OioEventLoopGroup以允许阻塞模式（旧的I/O）
　　　　　　　　.localAddress(new InetSocketAddress(port))
　　　　　　　  .childHandler(new ChannelInitializer<SocketChannel>() {  ← --  指定Channel-Initializer，对于每个已接受的连接都调用它
　　　　　　　　　　@Override
　　　　　　　　　 public void initChannel(SocketChannel ch)
　　　　　　　　　　　　throws Exception {
　　　　　　　　　　　　ch.pipeline().addLast(
　　　　　　　　　　　　　　new ChannelInboundHandlerAdapter() {  ← -- 添加一个Channel-InboundHandler-Adapter 以拦截和处理事件
　　　　　　　　　　　　　　　　@Override
　　　　　　　　　　　　　　　　public void channelActive(
　　　　　　　　　　　　　　　　　　ChannelHandlerContext ctx)
　　　　　　　　　　　　　　　　　　　　throws Exception {
　　　　　　　　　　　　　　　　　　ctx.writeAndFlush(buf.duplicate())
　　　　　　　　　　　　　　　　　　　　.addListener(
　　　　　　　　　　　　　　　　　　　　　　 ChannelFutureListener.CLOSE);   ← -- 将消息写到客户端，并添加ChannelFutureListener，以便消息一被写完就关闭连接
　　　　　　　　　　　　　　　　}
　　　　　　　　　　　　　　});
　　　　　　　　　　}
　　　　　　　　});
　　　　　　ChannelFuture f = b.bind().sync();  ← -- 绑定服务器以接受连接
　　　　　　f.channel().closeFuture().sync();
　　　　} finally {
　　　　　　group.shutdownGracefully().sync();　 ← -- 释放所有的资源
　　　　}
	}
}
```
非阻塞的Netty版本
```
public class NettyNioServer {
　　public void server(int port) throws Exception {
　　　 final ByteBuf buf = Unpooled.copiedBuffer("Hi!\r\n",
　　　　　 Charset.forName("UTF-8"));
       EventLoopGroup group = new NioEventLoopGroup();  ← --  为非阻塞模式使用NioEventLoopGroup
　　　　 try {
　　　　　　ServerBootstrap b = new ServerBootstrap();   ← --  创建ServerBootstrap
            b.group(group).channel(NioServerSocketChannel.class)
　　　　　　　　.localAddress(new InetSocketAddress(port))
　　　　　　　　.childHandler(new ChannelInitializer() {  ← --  指定Channel-Initializer，对于每个已接受的连接都调用它
　　　　　　　　　　@Override
　　　　　　　　　 public void initChannel(SocketChannel ch)
　　　　　　　　　　　 throws Exception{
　　　　　　　　　　　 ch.pipeline().addLast(
　　　　　　　　　　　　　new ChannelInboundHandlerAdapter() {  ← --  添加ChannelInbound-HandlerAdapter 以接收和处理事件
　　　　　　　　　　　　　　　　@Override
　　　　　　　　　　　　　　　　public void channelActive(
　　　　　　　　　　　　　　　　　 ChannelHandlerContext ctx) throws Exception {  ← -- 将消息写到客户端，并添加ChannelFutureListener，以便消息一被写完就关闭连接
　　　　　　　　　　　　　　　　　　ctx.writeAndFlush(buf.duplicate()) 
　　　　　　　　　　　　　　　　　　　　.addListener(
　　　　　　　　　　　　　　　　　　　　　　ChannelFutureListener.CLOSE);
　　　　　　　　　　　　　　　　}
　　　　　　　　　　　　});
　　　　　　　　　　}
　　　　　　　　});
　　　　　　ChannelFuture f = b.bind().sync();   ← -- 绑定服务器以接受连接
　　　　　　f.channel().closeFuture().sync();
　　　　} finally {
　　　　　　group.shutdownGracefully().sync();  ← -- 释放所有的资源
　　　　}
　　}
}
```

Netty为每种传输的实现都暴露了相同的API

![API](/static/开发/JAVA/imgs/Channel.png)

每个Channel都将会被分配一个ChannelPipeline和ChannelConfig,ChannelConfig包含了该Channel的所有配置设置，并且支持`热更新`

由于Channel是独一无二的，所以为了保证顺序将Channel声明为java.lang.Comparable的一个子接口。因此，如果两个不同的Channel实例都返回了相同的散列码，那么AbstractChannel中的compareTo()方法的实现将会抛出一个Error。

ChannelPipeline持有所有将应用于入站和出站数据以及事件的ChannelHandler实例,ChannelHandler实现了应用程序用于处理状态变化以及数据处理的逻辑。
ChannelHandler 典型用途：
 
 - 将数据从一种格式转换为另一种格式；
 - 提供异常的通知；
 - 提供Channel变为活动的或者非活动的通知；
 - 提供当Channel注册到EventLoop或者从EventLoop注销时的通知；
 - 提供有关用户自定义事件的通知。
 
ChannelPipeline实现了一种常见的设计模式——`拦截过滤器（Intercepting Filter）`

根据需要通过添加或者移除ChannelHandler实例来修改ChannelPipeline。通过利用Netty的这项能力可以构建出高度灵活的应用程序。

写数据：
```
Channel channel = ...
ByteBuf buf = Unpooled.copiedBuffer("your data", CharsetUtil.UTF_8);  	//← --  创建持有要写数据的ByteBuf
ChannelFuture cf = channel.writeAndFlush(buf);  						//← --  写数据并冲刷它
cf.addListener(new ChannelFutureListener() {　 						    //← -- 添加ChannelFutureListener 以便在写操作完成后接收通知
　　@Override
　　public void operationComplete(ChannelFuture future) {
　　　　if (future.isSuccess()) {　 									//← -- 写操作完成，并且没有错误发生　　
　　　　　　System.out.println("Write successful");
　　　　} else {
　　　　　　System.err.println("Write error");  						//← -- 记录错误
　　　　　　future.cause().printStackTrace();
　　　　}
　　}
});
```

Netty的`Channel实现是线程安全的`，因此你可以存储一个到Channel的引用，并且每当你需要向远程节点写数据时，都可以使用它,
消息将会被保证按顺序发送
```
final Channel channel = ...
final ByteBuf buf = Unpooled.copiedBuffer("your data", CharsetUtil.UTF_8).retain();   ← --  创建持有要写数据的ByteBuf
Runnable writer = new Runnable() {　  ← --  创建将数据写到Channel 的Runnable
　　@Override
　　public void run() {
　　　　channel.writeAndFlush(buf.duplicate());
　　}
};
Executor executor = Executors.newCachedThreadPool();   ← --  获取到线程池Executor 的引用

// write in one thread
executor.execute(writer);  ← --  递交写任务给线程池以便在某个线程中执行

// write in another thread
executor.execute(writer);　 ← --  递交另一个写任务以便在另一个线程中执行
...
```


Netty所提供的传输
|名　　称|包|描　　述|
|--|--|--|
|NIO|io.netty.channel.socket.nio|使用java.nio.channels包作为基础——基于选择器的方式|
|Epoll|io.netty.channel.epoll|由JNI驱动的epoll()和非阻塞IO。这个传输支持只有在Linux上可用的多种特性，如SO_REUSEPORT，比NIO传输更快，而且是完全非阻塞的|
|OIO|io.netty.channel.socket.oio|使用java.net包作为基础——使用阻塞流|
|Local|io.netty.channel.local|可以在VM内部通过管道进行通信的本地传输|
|Embedded|io.netty.channel.embedded|Embedded传输，允许使用ChannelHandler而又不需要一个真正的基于网络的传输。这在测试你的ChannelHandler实现时非常有用|

## 8.1 NIO
NIO传输基于Java提供的异步/非阻塞网络编程的通用抽象，虽保证了Netty的`非阻塞API`可以在`任何平台`上使用，
但它也包含了相应的限制，因为JDK为了在所有系统上提供相同的功能，必须做出妥协。
NIO 可能的变化:
- 新的Channel已被接受并且就绪；
- Channel连接已经完成；
- Channel有已经就绪的可供读取的数据；
- Channel可用于写数据。

`java.nio.channels.SelectionKey`定义的`位模式`。这些位模式可以组合起来定义一组应用程序正在请求通知的`状态变化集`。
选择操作的位模式:
- OP_ACCEPT	请求在接受新连接并创建Channel时获得通知
- OP_CONNECT 请求在建立一个连接时获得通知
- OP_READ  请求当数据已经就绪，可以从Channel中读取时获得通知
- OP_WRITE 请求当可以向Channel中写更多的数据时获得通知。这处理了套接字缓冲区被完全填满时的情况，这种情况通常发生在数据的发送速度比远程节点可处理的速度更快的时候
用户级别API完全地隐藏了这些NIO的内部细节

![位模式 状态](/static/开发/JAVA/imgs/Channel-1.png)

## Epoll——用于Linux的本地非阻塞传输
epoll——一个高度可扩展的I/O事件通知特性
这个API自Linux内核版本`2.5.44（2002）`被引入，提供了比旧的`POSIX select`和`poll系统`调用更好的性能
epoll是Linux上非阻塞网络编程的事实标准。
`Linux JDK NIO API`使用了这些epoll调用
使用epoll替代NIO，只需要将NioEventLoopGroup替换为EpollEventLoopGroup，并且将NioServerSocketChannel.class替换为EpollServerSocketChannel.class即可。


## OIO——旧的阻塞I/O
通过常规的传输API使用，但是由于它是建立在java.net包的阻塞实现之上的，所以它不是异步的。
Netty利用了SO_TIMEOUT这个Socket标志，它指定了等待一个I/O操作完成的最大毫秒数。如果操作在指定的时间间隔内没有完成，则将会抛出一个SocketTimeout Exception。Netty将捕获这个异常并继续处理循环。在EventLoop下一次运行时，它将再次尝试。这实际上也是类似于Netty这样的异步框架能够支持OIO的唯一方式

## JVM内部通信的Local传输
在同一个JVM中运行的客户端和服务器程序之间的异步通信,这种传输方式也支持对于所有Netty传输实现都共同的API。
和服务器Channel相关联的SocketAddress并没有绑定物理网络地址；相反，只要服务器还在运行，它就会被存储在注册表里，并在Channel关闭时注销。
不接受真正的网络流量，所以它并不能够和其他传输实现进行互操作
客户端希望连接到（在同一个JVM中）使用了这个传输的服务器端时也必须使用它。

## Embedded传输
一种额外的传输，使得你可以将一组ChannelHandler作为帮助器类嵌入到其他的ChannelHandler内部。
通过这种方式，你将可以扩展一个ChannelHandler的功能，而又不需要修改其内部代码。
使用这个类来为ChannelHandler的实现创建单元测试用例


# 9. ByteBuf
Netty的ByteBuffer替代品是ByteBuf，解决了JDK API的局限性
`abstract class ByteBuf`和`interface ByteBufHolder`

ByteBuf API:
- 它可以被用户自定义的缓冲区类型扩展；
- 通过内置的复合缓冲区类型实现了透明的零拷贝；
- 容量可以按需增长（类似于JDK的StringBuilder）；
- 在读和写这两种模式之间切换不需要调用ByteBuffer的flip()方法；
- 读和写使用了不同的索引；
- 支持方法的链式调用；
- 支持引用计数；
- 支持池化。


ByteBuf的两个索引readerIndex,writerIndex， 起始位置均为0
名称以read或者write开头的ByteBuf方法，将会`推进`其对应的索引，而名称以set或者get开头的操作则`不会`
可以指定ByteBuf的最大容量(Integer.MAX_VALUE(默认))

一个由`不同的索引`分别控制`读`访问和`写`访问的字节数组。

## 9.1 使用模式：

1. 堆缓冲区
将数据存储在JVM的堆空间中。这种模式被称为支撑数组（backing array），
能在没有使用池化的情况下提供快速的分配和释放
似于JDK的ByteBuffer的用法

```
ByteBuf heapBuf = ...;
if (heapBuf.hasArray()) {  					← --  检查ByteBuf 是否有一个支撑数组
　　byte[] array = heapBuf.array();  		← --  如果有，则获取对该数组的引用　
　　int offset = heapBuf.arrayOffset() + heapBuf.readerIndex();  ← --  计算第一个字节的偏移量。
　　int length = heapBuf.readableBytes();　 ← --  获得可读字节数
　　handleArray(array, offset, length);　 	← --  使用数组、偏移量和长度作为参数调用你的方法
}

```

2. 直接缓冲区
我们·`期望`用于对象创建的`内存分配`永远都来自于`堆`中,
但并不是必须的,NIO在JDK 1.4中引入的ByteBuffer类允许JVM实现通过本地调用来分配内存
为了避免在每次调用本地I/O操作之前（或者之后）将缓冲区的内容复制到一个中间缓冲区（或者从中间缓冲区把内容复制到缓冲区）

直接缓冲区的内容将`驻留`在`常规的会被垃圾回收`的堆之`外`。
如果你的数据包含在一个在堆上分配的缓冲区中，那么事实上，在通过套接字发送它之前，JVM将会在内部把你的缓冲区复制到一个直接缓冲区中。

相对于堆缓冲区：
缺点：
分配和释放都较为昂贵
处理遗留代码：因为数据不是在堆上，所以你不得不进行一次复制
支撑数组相比，这涉及的工作更多
```
ByteBuf directBuf = ...; 
if (!directBuf.hasArray()) {  ← --  检查ByteBuf 是否由数组支撑。如果不是，则这是一个直接缓冲区
　　int length = directBuf.readableBytes();  ← --  获取可读字节数
　　byte[] array = new byte[length];　		 ← --  分配一个新的数组来保存具有该长度的字节数据　　
　　directBuf.getBytes(directBuf.readerIndex(), array);  ← --  将字节复制到该数组
　　handleArray(array, 0, length);  		← --  使用数组、偏移量和长度作为参数调用你的方法
}
```

3．复合缓冲区
为多个ByteBuf提供一个聚合视图,可根据需要添加或者删除ByteBuf实例
Netty通过一个ByteBuf子类(CompositeByteBuf)实现了这个模式
将多个缓冲区表示为单个合并缓冲区的虚拟表示
CompositeByteBuf 实例 可能同时包含直接内存分配和非直接内存分配
如果其中只有一个实例,hasArray()方法的调用将返回该组件上的hasArray()方法的值；否则它将返回false。

场景描述：
HTTP协议=头部和主体，两部分由应用程序的不同模块产生，消息被发送的时候组装
多个消息重用相同的消息主体，不想为每个消息都重新分配这两个缓冲区
CompositeByteBuf是一个完美的选择。它在消除了没必要的复制的同时
```
#JDK的ByteBuffer来实现

// Use an array to hold the message parts
ByteBuffer[] message = new ByteBuffer[] { header, body };
// Create a new ByteBuffer and use copy to merge the header and body
ByteBuffer message2 =
　　ByteBuffer.allocate(header.remaining() + body.remaining());
message2.put(header);
message2.put(body);
message2.flip();

#使用CompositeByteBuf的复合缓冲区模式

CompositeByteBuf messageBuf = Unpooled.compositeBuffer();
ByteBuf headerBuf = ...; // can be backing or direct
ByteBuf bodyBuf = ...;　 // can be backing or direct
messageBuf.addComponents(headerBuf, bodyBuf);  ← --  将ByteBuf 实例追加到CompositeByteBuf
.....
messageBuf.removeComponent(0); // remove the header　 ← -- 删除位于索引位置为 0（第一个组件）的ByteBuf
for (ByteBuf buf : messageBuf) {  ← -- 循环遍历所有的ByteBuf 实例
　　System.out.println(buf.toString());
}

#访问CompositeByteBuf中的数据
#可能不支持访问其支撑数组，因此访问CompositeByteBuf中的数据类似于（访问）直接缓冲区的模式
CompositeByteBuf compBuf = Unpooled.compositeBuffer();
int length = compBuf.readableBytes();  ← --  获得可读字节数
byte[] array = new byte[length];　 ← --  分配一个具有可读字节数长度的新数组
compBuf.getBytes(compBuf.readerIndex(), array);  ← --  将字节读到该数组中
handleArray(array, 0, array.length);  ← --  使用偏移量和长度作为参数使用该数组
```

Netty使用了CompositeByteBuf来优化套接字的I/O操作，
尽可能地消除了由JDK的缓冲区实现所导致的性能以及`内存使用率的惩罚`。
这种优化发生在Netty的核心代码中


ByteBuf的索引是从零开始的：
第一个字节的索引是`0`，
最后一个字节的索引总是`capacity() - 1`

使用那些需要一个`索引值参数`的方法（的其中）之一来访问数据
既`不会`改变readerIndex也不会改变writerIndex。

如果有需要，可通过调用`readerIndex(index)`或者`writerIndex(index)`来手动移动这两者。

ByteBuf同时具有`读索引`和`写索引`,
但是JDK的ByteBuffer却`只有一个索引`,
这也是必须调用flip()方法来在`读模式`和`写模式`之间进行`切换`的原因

ByteBuf : 

```
|可丢弃字节| 可读字节   |  可写字节   |
0       readIndex  writerIndex     capacity

可丢弃字节:通过调用discardReadBytes()方法 回收空间
在调用discardReadBytes()之后，对可写分段的内容并没有任何的保证
| 可读字节   |  可写字节   				|
readIndex  writerIndex     			capacity
0

调用discardReadBytes()方法以确保可写分段的最大化,
频繁地调用可能会导致内存复制,因为可读字节必须被移动到缓冲区的开始位置



```
任何名称以`read`或者`skip`开头的操作都将检索或者跳过位于当前readerIndex的数据，
并且将它`增加已读`字节数。

被调用的方法需要一个ByteBuf参数作为写入的目标，并且没有指定目标索引参数，那么该目标缓冲区的writerIndex也将被增加
`readBytes(ByteBuf dest);`

```
ByteBuf buffer = ...;
while (buffer.isReadable()) {
　　System.out.println(buffer.readByte());
}
```

`write`开头的操作都将从当前的writerIndex处开始写数据，并将它增加已经写入的字节数
目标也是ByteBuf，并且没有指定源索引的值，则源缓冲区的readerIndex也同样会被增加相同的大小
`writeBytes(ByteBuf dest);`
```
ByteBuf buffer = ...;
while (buffer.writableBytes() >= 4) {
　　buffer.writeInt(random.nextInt());
}
```

## 9.2 索引管理
JDK的InputStream定义了`mark(int readlimit)`和`reset()`方法
用来将流中的当前位置标记为指定的值，以及将流重置到该位置

通过调用`markReaderIndex()`、`markWriterIndex()`、`resetWriterIndex()`和`resetReaderIndex()`来标记和重置ByteBuf的readerIndex和writerIndex

也可以通过调用readerIndex(int)或者writerIndex(int)来将索引移动到指定位置
无效的位置都将导致一个IndexOutOfBoundsException。
clear()方法来将readerIndex和writerIndex都设置为0 并不会清除内存中的内容

调用clear()比调用discardReadBytes()轻量得多，因为它将只是重置索引而不会复制任何的内存。

查找
```
ByteBuf buffer = ...;
int index = buffer.forEachByte(ByteBufProcessor.FIND_CR);
//ByteBufProcessor.FIND_NUL
```

## 9.3 派生缓冲区
以专门的方式来呈现其内容的视图
```
duplicate()；
slice()；
slice(int, int)；
Unpooled.unmodifiableBuffer(…)；
order(ByteOrder)；
readSlice(int)。·
```
返回一个新的ByteBuf实例,
具有自己的读索引、写索引和标记索引。
其内部存储和JDK的`ByteBuffer一样也是共享`的。
这使得派生缓冲区的`创建成本`是很`低廉`的，
但是这也意味着，如果你修改了它的内容，也同时修改了其对应的源实例，所以要小心。

ByteBuf复制:
现有缓冲区的真实副本，请使用`copy()`或者`copy(int, int)`方法。不同于派生缓冲区，由这个调用所返回的ByteBuf拥有独立的数据副本。

`slice(int,int)` 切片
`copy(int, int)` 分段的副本

```
Charset utf8 = Charset.forName("UTF-8");
 ByteBuf buf = Unpooled.copiedBuffer("Netty in Action rocks!", utf8);  ← --  创建ByteBuf 以保存所提供的字符串的字节
 ByteBuf copy = buf.copy(0, 15);　 ← --  创建该ByteBuf 从索引0 开始到索引15结束的分段的副本
System.out.println(copy.toString(utf8));　 ← --   将打印“Netty in Action”
buf.setByte(0, (byte) 'J');　 ← --  更新索引0 处的字节 
assert buf.getByte(0) != copy.getByte(0);  ← --  将会成功，因为数据不是共享的
```



|名　　称			|描　　述
|--|--|
|isReadable()		|如果至少有一个字节可供读取，则返回true
|isWritable()		|如果至少有一个字节可被写入，则返回true
|readableBytes()	|返回可被读取的字节数
|writableBytes()	|	返回可被写入的字节数
|capacity()			|返回ByteBuf可容纳的字节数。在此之后，它会尝试再次扩展直 到达到maxCapacity()
|maxCapacity()		|返回ByteBuf可以容纳的最大字节数
|hasArray()			|如果ByteBuf由一个字节数组支撑，则返回true
|array()			|	如果 ByteBuf由一个字节数组支撑则返回该数组；否则，它将抛出一个UnsupportedOperationException异常

## 9.4 其他接口

ByteBufHolder 存储各种属性值

ByteBufAllocator  按需分配 降低分配和释放内存的开销 `（ByteBuf的）池化`
```
Channel channel = ...;
ByteBufAllocator allocator = channel.alloc();  ← --  从Channel 获取一个到ByteBufAllocator 的引用
....
ChannelHandlerContext ctx = ...;
ByteBufAllocator allocator2 = ctx.alloc();　 ← --  从ChannelHandlerContext 获取一个到ByteBufAllocator 的引用
...
```

Unpooled缓冲区: `未能获取`一个到`ByteBufAllocator的引用` 一个简单的称为Unpooled的工具类

ByteBufUtil类  操作ByteBuf的静态的辅助方法


### 9.5 引用计数
引用计数是一种通过在某个对象所持有的资源不再被其他对象引用时释放该对象所持有的资源来优化内存使用和性能的技术
Netty在第4版中为ByteBuf和ByteBufHolder引入了引用计数技术，它们都实现了interface ReferenceCounted。


通常以活动的引用计数为`1`作为开始。只要引用计数大于0，就能保证对象不会被释放。当活动引用的数量减少到0时，该实例就会被释放。注意，虽然释放的确切语义可能是特定于实现的，但是至少已经释放的对象应该不可再用了。

引用计数对于池化实现（如PooledByteBufAllocator）来说是至关重要的，它降低了内存分配的开销。
```
Channel channel = ...;
ByteBufAllocator allocator = channel.alloc();  ← --  从Channel 获取ByteBufAllocator
....
ByteBuf buffer = allocator.directBuffer();　 ← --  从ByteBufAllocator分配一个ByteBuf　　　　
assert buffer.refCnt() == 1; ← --  检查引用计数是否为预期的1
...
```
```

ByteBuf buffer = ...;
boolean released = buffer.release();  ← --  减少到该对象的活动引用。当减少到0 时，该对象被释放，并且该方法返回true
...
```

每当通过调用channelRead()或者.write()方法来处理数据时，你都需要确保没有任何的资源泄漏。
Netty提供了`ResourceLeakDetector` 对 应用程序的缓冲区分配做大约1%的采样来检测内存泄露

|级别|描述|
|--|--|
|DISABLED|禁用泄漏检测。只有在详尽的测试之后才应设置为这个值
|SIMPLE|使用1%的默认采样率检测并报告任何发现的泄露。这是默认级别，适合绝大部分的情况
|ADVANCED|使用默认的采样率，报告所发现的任何的泄露以及对应的消息被访问的位置
|PARANOID|类似于ADVANCED，但是其将会对每次（对消息的）访问都进行采样。这对性能将会有很大的影响，应该只在调试阶段使用

```
java -Dio.netty.leakDetectionLevel=ADVANCED
```
检测到了内存泄露日志消息

```
LEAK: ByteBuf.release() was not called before it's garbage-collected. Enable
advanced leak reporting to find out where the leak occurred. To enable
advanced leak reporting, specify the JVM option
'-Dio.netty.leakDetectionLevel=ADVANCED' or call
ResourceLeakDetector.setLevel().
```

# 10. 单元测试

 ChannelHandler是Netty应用程序的关键元素，
 一种特殊的Channel实现`EmbeddedChannel`，它是Netty专门为改进针对ChannelHandler的单元测试而提供的,
用JUnit 4作为我们的测试框架

<font color="red">可以将ChannelPipeline中的ChannelHandler实现链接在一起，以构建你的应用程序的业务逻辑。 
这种设计支持将任何潜在的复杂处理过程分解为小的可重用的组件，每个组件都将处理一个明确定义的任务或者步骤。</font>

Netty提供了它所谓的Embedded传输，用于测试ChannelHandler。这个传输是一种特殊的Channel实现,这个实现提供了通过ChannelPipeline传播事件的简便方法。

将入站数据或者出站数据写入到EmbeddedChannel中，然后检查是否有任何东西到达了ChannelPipeline的尾端。以这种方式，你便可以确定消息是否已经被编码或者被解码过了，以及是否触发了任何的ChannelHandler动作。

|名　　称|职　　责|
|--|--|
|writeInbound(　　 Object... msgs) |将入站消息写到EmbeddedChannel中。如果可以通过readInbound()方法从EmbeddedChannel中读取数据，则返回true|
|readInbound()|从EmbeddedChannel中读取一个入站消息。任何返回的东西都穿越了整个ChannelPipeline。如果没有任何可供读取的，则返回null|
|writeOutbound(　　 Object... msgs)|将出站消息写到EmbeddedChannel中。如果现在可以通过readOutbound()方法从EmbeddedChannel中读取到什么东西，则返回true|
|readOutbound()|从EmbeddedChannel中读取一个出站消息。任何返回的东西都穿越了整个ChannelPipeline。如果没有任何可供读取的，则返回null|
|finish()|将EmbeddedChannel标记为完成，并且如果有可被读取的入站数据或者出站数据，则返回true。这个方法还将会调用EmbeddedChannel上的close()方法|

使用EmbeddedChannel的方法，数据是如何流经ChannelPipeline的。你可以使用writeOutbound()方法将消息写到Channel中，并通过ChannelPipeline沿着出站的方向传递。随后，你可以使用readOutbound()方法来读取已被处理过的消息，以确定结果是否和预期一样。 类似地，对于入站数据，你需要使用writeInbound()和readInbound()方法。

![单元测试——EmbeddedChannel](/static/开发/JAVA/imgs/EmbeddedChannel.png)


## 10.1. 解码器测试
``` java
public class FixedLengthFrameDecoder extends ByteToMessageDecoder {   	//← --  扩展ByteToMessageDecoder 以处理入站字节，并将它们解码为消息
　　private final int frameLength;

　　public FixedLengthFrameDecoder(int frameLength) {　  					//← -- 指定要生成的帧的长度
　　　　if (frameLength <= 0) {
　　　　　　throw new IllegalArgumentException(
　　　　　　　　"frameLength must be a positive integer: " + frameLength);
　　　　}
　　　　this.frameLength = frameLength;
　　}
　　@Override

　　protected void decode(ChannelHandlerContext ctx, ByteBuf in,
　　　　List<Object> out) throws Exception {
　　　　while (in.readableBytes() >= frameLength) {　 					//← --   检查是否有足够的字节可以被读取，以生成下一个帧
　　　　　　ByteBuf buf = in.readBytes(frameLength);　 					//← --  从ByteBuf 中读取一个新帧
　　　　　　out.add(buf);　 												//← --  将该帧添加到已被解码的消息列表中 
　　　　}
　　}
}

```

```java
public class FixedLengthFrameDecoderTest {  					//← --  使用了注解@Test 标注，因此JUnit 将会执行该方法
　　@Test 
　　public void testFramesDecoded() {　	// ← --  第一个测试方法：testFramesDecoded()
　　　　ByteBuf buf = Unpooled.buffer();　  //← -- 创建一个ByteBuf，并存储9 字节
　　　　for (int i = 0; i < 9; i++) {
　　　　　　 buf.writeByte(i);
　　　　}
　　　　ByteBuf input = buf.duplicate();
　　　　EmbeddedChannel channel = new EmbeddedChannel(    //← -- 创建一个EmbeddedChannel，并添加一个FixedLengthFrameDecoder，其将以3 字节的帧长度被测试
　　　　　　new FixedLengthFrameDecoder(3));
　　　　// write bytes
　　　　assertTrue(channel.writeInbound(input.retain()));   // ← -- 将数据写入Embedded-Channel
　　　　assertTrue(channel.finish());　						// ← -- 标记Channel为已完成状态　

　　　　// read messages　 ← -- 读取所生成的消息，并且验证是否有3 帧（切片），其中每帧（切片）都为3 字节
　　　　ByteBuf read = (ByteBuf) channel.readInbound();
　　　　assertEquals(buf.readSlice(3), read);
　　　　read.release();

　　　　read = (ByteBuf) channel.readInbound();
　　　　assertEquals(buf.readSlice(3), read);
　　　　read.release();

　　　　read = (ByteBuf) channel.readInbound();
　　　　assertEquals(buf.readSlice(3), read);
　　　　read.release();

　　　　assertNull(channel.readInbound());
　　　　buf.release();
　　}

　　@Test
　　public void testFramesDecoded2() {　 ← --  第二个测试方法：testFramesDecoded2()　
　　　　ByteBuf buf = Unpooled.buffer();
　　　　for (int i = 0; i < 9; i++) {
　　　　　　buf.writeByte(i);
　　　　}
　　　　ByteBuf input = buf.duplicate();

　　　　EmbeddedChannel channel = new EmbeddedChannel(
　　　　　　new FixedLengthFrameDecoder(3));
　　　　assertFalse(channel.writeInbound(input.readBytes(2)));   ← --  返回false，因为没有一个完整的可供读取的帧
　　　　assertTrue(channel.writeInbound(input.readBytes(7)));

　　　　assertTrue(channel.finish());
　　　　ByteBuf read = (ByteBuf) channel.readInbound();
　　　　assertEquals(buf.readSlice(3), read);
　　　　read.release();

　　　　read = (ByteBuf) channel.readInbound();
　　　　assertEquals(buf.readSlice(3), read);
　　　　read.release();

　　　　read = (ByteBuf) channel.readInbound();
　　　　assertEquals(buf.readSlice(3), read);
　　　　read.release();

　　　　assertNull(channel.readInbound());
　　　　buf.release();
　　}
}

```


# 10.3. 出站数据测试：
```java
public class AbsIntegerEncoder extends
　　MessageToMessageEncoder<ByteBuf> {　  ← --  扩展MessageToMessageEncoder 以将一个消息编码为另外一种格式
　　@Override
　　protected void encode(ChannelHandlerContext channelHandlerContext,
　　　　ByteBuf in, List<Object> out) throws Exception {
![..\tu\p45-2.tif{25}](/api/storage/getbykey/original?key=17058221f3a645320473)　　　　while (in.readableBytes() >= 4) {　  ← -- 检查是否有足够的字节用来编码
　　　　　　int value = Math.abs(in.readInt());　 ← --  从输入的ByteBuf中读取下一个整数，并且计算其绝对值
　　　　　　out.add(value);　 ← --  将该整数写入到编码消息的List 中
　　　　}
　　}
}


```

```java
public class AbsIntegerEncoderTest {
　　@Test
　　public void testEncoded() {
　　　　ByteBuf buf = Unpooled.buffer();   			← --  ❶创建一个ByteBuf，并且写入9 个负整数
　　　　for (int i = 1; i < 10; i++) {
　　　　　　buf.writeInt(i * -1);
　　　　}

　　　　EmbeddedChannel channel = new EmbeddedChannel( ← -- ❷创建一个EmbeddedChannel，并安装一个要测试的AbsIntegerEncoder
　　　　　　new AbsIntegerEncoder());
　　　　assertTrue(channel.writeOutbound(buf));  	← -- ❸写入ByteBuf，并断言调用readOutbound()方法将会产生数据 
　　　　assertTrue(channel.finish());  				← -- ❹将该Channel标记为已完成状态

　　　　// read bytes　
　　　 for (int i = 1; i < 10; i++) {  			← -- ❺读取所产生的消息，并断言它们包含了对应的绝对值
　　　　　　assertEquals(i, channel.readOutbound());
　　　　}
　　　　assertNull(channel.readOutbound());
　　}
}

```

## 10.4. 测试异常处理

如果所读取的字节数超出了某个特定的限制，我们将会抛出一个TooLongFrameException
```java
public class FrameChunkDecoder extends ByteToMessageDecoder {   ← --  扩展ByteToMessage-Decoder 以将入站字节解码为消息
　　private final int maxFrameSize;

　　public FrameChunkDecoder(int maxFrameSize) {  ← --  指定将要产生的帧的最大允许大小
　　　　this.maxFrameSize = maxFrameSize;
　　}

　　@Override
　　protected void decode(ChannelHandlerContext ctx, ByteBuf in,
　　　　List<Object> out) throws Exception {
　　　　int readableBytes = in.readableBytes();　
　　　　if (readableBytes > maxFrameSize) {
　　　　　　// discard the bytes　 ← --  如果该帧太大，则丢弃它并抛 出一个TooLongFrameException……
　　　　　　in.clear();
　　　　　　throw new TooLongFrameException();
　　　　}
　　　　ByteBuf buf = in.readBytes(readableBytes);  ← -- ……否则，从ByteBuf 中读取一个新的帧　　
　　　　out.add(buf);　　 ← --  将该帧添加到解码消息的List 中
　　}
}

```

Test
```java
public class FrameChunkDecoderTest {
　　@Test
　　public void testFramesDecoded() {
　　　　ByteBuf buf = Unpooled.buffer();   ← --  创建一个ByteBuf，并向它写入9 字节
　　　　for (int i = 0; i < 9; i++) {
　　　　　　buf.writeByte(i);
　　　　}
　　　   ByteBuf input = buf.duplicate();

　　　　EmbeddedChannel channel = new EmbeddedChannel(
　　　　　　new FrameChunkDecoder(3));　 ← --  创建一个EmbeddedChannel，并向其安装一个帧大小为3 字节
的FixedLengthFrameDecoder
　　　　assertTrue(channel.writeInbound(input.readBytes(2)));  ← -- 向它写入2 字节，并断言它们将会产生一个新帧 
　　　　try {
　　　　　 channel.writeInbound(input.readBytes(4));　 ← -- 写入一个4 字节大小的帧，并捕获预期的TooLongFrameException
　　　　　　Assert.fail();　 ← -- 如果上面没有抛出异常，那么就会到达这个断言，并且测试失败
　　　　} catch (TooLongFrameException e) {
　　　　　　// expected exception
　　　　}
　　　　assertTrue(channel.writeInbound(input.readBytes(3)));  ← -- 写入剩余的2 字节，并断言将会产生一个有效帧 
　　　　assertTrue(channel.finish());　  ← -- 将该Channel 标记为已完成状态

　　　　// Read frames　  ← -- 读取产 生的消息，并且验证值
　　　　ByteBuf read = (ByteBuf) channel.readInbound();
　　　　assertEquals(buf.readSlice(2), read);
　　　　read.release();

　　　　read = (ByteBuf) channel.readInbound();
　　　　assertEquals(buf.skipBytes(4).readSlice(3), read);
　　　　read.release();
　　　　buf.release();
　　}
}


```
这里使用的try/catch块是EmbeddedChannel的一个特殊功能。如果其中一个write*方法产生了一个受检查的Exception，那么它将会被包装在一个RuntimeException中并抛出[1]。这使得可以容易地测试出一个Exception是否在处理数据的过程中已经被处理了。
