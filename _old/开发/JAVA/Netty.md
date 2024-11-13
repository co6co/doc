---
layout: post
title: Netty
subtitle:
date:       2021-09-27 11:32:52
categories: [JAVA]
tags: [JAVA,Netty]
---


 asynchronous event-driven （异步事件驱动）的网络应用框架
 Netty 大大简化了网络程序的开发过程比如 TCP 和 UDP 的 socket 服务的开发
 哲学设计理念
 [netty 架构图](./static/开发/JAVA/imgs/netty/架构图.png)
 
 Transparent Zero Copy 透明的零拷贝
 
 
 Java 新的I/O（NIO）API与原有的阻塞式的I/O（OIO）[Old I/O] API 并不兼容，NIO.2(AIO)也是如此
 复杂的 NIO Selector 编程接口
 
 Netty 有一个叫做 Channel 的统一的异步 I/O 编程接口,抽象了所有点对点的通信操作
 你的应用是基于 Netty 的某一种传输实现，那么同样的，你的应用也可以运行在 Netty 的另一种传输实现上
 几种拥有相同编程接口的基本传输实现:
- 基于 NIO 的 TCP/IP 传输 (见 io.netty.channel.nio),
- 基于 OIO 的 TCP/IP 传输 (见 io.netty.channel.oio),
- 基于 OIO 的 UDP/IP 传输 
- 本地传输 (见 io.netty.channel.local).

切换不同的传输实现通常只需对代码进行`几行的修改调整` 选择一个不同的 `ChannelFactory 实现`


Event Model based on the `Interceptor Chain` Pattern 基于拦截链模式的事件模型

具有定义`良好的 I/O 事件模型`,允许你在不破坏现有代码的情况下`实现自己的事件类型`
~~很多 NIO 框架没有或者仅有有限的事件模型概念；在你试图添加一个新的事件类型的时候常常需要修改已有的代码，或者根本就不允许你进行这种扩展。~~

# 2.核心组件:
 `ChannelPipeline` 内部一个 `ChannelEvent` 被一组`ChannelHandler` 处理。
 这个管道是 `Intercepting Filter` (拦截过滤器)模式的一种高级形式的实现，
 因此对于一个事件如何被处理以及管道内部处理器间的交互过程，你都将拥有绝对的控制力
 ```
 MyReadHandler implements SimpleChannelHandler{
	public void messageReceived(ChannelHandlerContext ctx, MessageEvent evt) {
		 Object message = evt.getMessage();
         ctx.sendUpstream(evt);// And forward the event to the next handler.
	}
	public void writeRequested(ChannelHandlerContext ctx, MessageEvent evt) {
        Object message = evt.getMessage();
        ctx.sendDownstream(evt);// And forward the event to the next handler.
    }
 }
 ```
 
 ByteBuf  					一个引用计数对象 显示地调用 release() 方法来释放
 
 处理器的职责是`释放所有传递到处理器的引用计数对象`  
 `ReferenceCountUtil.release(msg);`
 `chanelRead()` 事件处理方法  	#收到新的数据
 `exceptionCaught() `			#方法是当出现 Throwable 对象才会被调用
								#IO 错误或者处理器在处理事件时抛出的异常时
				记录异常，关闭关联的 channel
				遇到不同异常的情况下有不同的实现，比如：发送一个`错误码的响应消息`
	
 
 ## 2.1 NioEventLoopGroup 
 处理I/O操作的多线程事件循环器,Netty 提供了许多不同的 `EventLoopGroup` 的实现用来处理不同的传输
 `NioEventLoopGroup boss` -->处理接收进来的连接
				 `worker` -->处理已经被接收的连接
				 
`boss`接收到连接，就会把连接信息`注册`到`worker`上,
`线程`\ `Channel`  依赖于  `EventLoopGroup` 的实现,可通过`构造函数`来配置他们的关系

## 2.2 ServerBootstrap
启动 NIO 服务的`辅助启动类`,可以在`ServerBootstrap`直接使用 `Channel`，但是一个复杂的处理过程


## 2.3  NioServerSocketChannel 
ChannelInitializer 配置新的 配置一个新的 Channel

## 2.4 ByteBuf
NIO 发送消息时调用 `java.nio.ByteBuffer.flip() `,
ByteBuf 有两个指针 读操作 写操作,写入数据的时候写指针的索引就会增加，同时读指针的索引没有变化
读指针索引和写指针索引分别代表了消息的开始和结束


## 2.5 ChannelFuture 
代表了一个还没有发生的 I/O 操作,味着任何一个请求操作都不会马上被执行，
因为在 Netty 里所有的操作都是异步的
要完成操作 需要构建 `ChannelFutureListener` 来完成操作.
## 2.6 增加多个 ChannelHandler 
增加`多个 ChannelHandler` 到`ChannelPipeline  ` 减少复杂度 

`ByteToMessageDecoder` 是 ChannelInboundHandler 的一个实现类，
他可以在处理`数据拆分`的问题上变得很简单。
开箱即用的解码器使你可以更简单地实现更多的协议
`ReplayingDecoder`

## 2.7 关闭
关闭一个 Netty 应用往往只需要简单地通过 `shutdownGracefully() `
方法来关闭你构建的所有的 EventLoopGroup。
当EventLoopGroup 被完全地终止,并且对应的所有 channel 都已经被关闭时，
Netty 会返回一个Future对象来通知你
 
# 3. 高级组件
 加速开发过程。
## 3.1 Codec 框架
 从业务逻辑代码中分离协议处理部分,
 可扩展，可重用，可单元测试并且是多层的 codec 框架,
 
 Netty 提供了一组构建在其核心模块之上的 codec 实现
 
 ## 3.2 SSL / TLS
 
 在 NIO 模式下支持 SSL 功能是一个艰难的工作
 不能只是简单的包装一下流数据并进行加密或解密工作,
 不得不借助于 javax.net.ssl.SSLEngine-->有状态的实现(密码套件，密钥协商（或重新协商），证书交换以及认证等)，其复杂性不亚于 SSL 自身
 SSLEngine 甚至不是一个绝对的线程安全实现
 
 Netty 内部，`SslHandler` 封装了所有艰难的细节以及使用 SSLEngine 可能带来的陷阱
 
 使用：配置并将该 SslHandler 插入到你的 ChannelPipeline 中
 
 Netty 也允许你实现像 StartTlS 那样所拥有的高级特性
 
 
 ## 3.3 HTTP
 
 有 类似 `Servlet容器`实现
 Netty 在HTTP 消息的低层交互过程中你将拥有`绝对`的控制力。
 
 `HTTP codec `和 `HTTP 消息类`的简单组合,可以随心所欲的编写完全按照你期望的工作方式工作的客户端或服务器端代码
 线程模型，连接生命期，快编码，以及所有 HTTP 协议允许你做的
 可以开发一个非常高效的HTTP服务器:
- 要求持久化链接以及服务器端推送技术的聊天服务（如，Comet )
- 需要保持链接直至整个文件下载完成的媒体流服务（如，2小时长的电影）
- 需要上传大文件并且没有内存压力的文件服务（如，上传1GB文件的请求）
- 支持大规模混合客户端应用用于连接以万计的第三方异步 web 服务。


## 3.4 WebSockets
双向，全双工通信信道 允许一个 Web 浏览器和 Web 服务器之间通过数据流交互 被 IETF 列为 RFC 6455规范

## 3.5 Google Protocol Buffer
快速实现一个高效的`二进制协议`的理想方案,
使用 ProtobufEncoder 和 ProtobufDecoder,
把 Google Protocol Buffers 编译器 (protoc) 生成的消息类放入到 Netty 的codec 实现中

 
 
# 4.  日志系统
`SLF4J`其实是一个`日志门面`(facade)，
它可以充当`Log4j`, `Logback`等日志框架的包装器。因此你的应用除了要有slf4j的依赖包，还要有其它具体的日志实现框架的依赖。
 Netty 实现了一套日志机制，但这套日志机制并不会真正去打日志。相反，Netty自身的日志机制更像一个`日志包装层。`
 
 启动时检测classpath下是否已经有其它的日志框架，
 检测顺序
 
 a. `slf4j`，
 b. `Log4j`
 c. JDK自带的日志框架`JDK Logging`。
 
 虽然Netty支持Common Logging,没有去检测Common Logging，即使有支持Common Logging的代码存在
 InternalLoggerFactory
 ```
     static {
        final String name = InternalLoggerFactory.class.getName();
        InternalLoggerFactory f;
        try {
            f = new Slf4JLoggerFactory(true);											//开始检测SLF4J是否存在
            f.newInstance(name).debug("Using SLF4J as the default logging framework");
            defaultFactory = f;
        } catch (Throwable t1) {
            try {
                f = new Log4JLoggerFactory();
                f.newInstance(name).debug("Using Log4J as the default logging framework");
            } catch (Throwable t2) {
                f = new JdkLoggerFactory();
                f.newInstance(name).debug("Using java.util.logging as the default logging framework");
            }
        }
        defaultFactory = f;
    } 
	
 ```
 
 # 4.1 检测SLF4J
 
 应用的classpath下存在slf4j相关的jar包,存在使用 Slf4JLogger
 
 ```
 Slf4JLoggerFactory(boolean failIfNOP) {
        assert failIfNOP; 
        final StringBuffer buf = new StringBuffer();
        final PrintStream err = System.err;
        try {
            System.setErr(new PrintStream(new OutputStream() {
                @Override
                public void write(int b) {
                    buf.append((char) b);
                }
            }, true, "US-ASCII"));
        } catch (UnsupportedEncodingException e) {
            throw new Error(e);
        }
        try {
			//只有slf4j 没有 没有logback
            if (LoggerFactory.getILoggerFactory() instanceof NOPLoggerFactory) {
                throw new NoClassDefFoundError(buf.toString());
            } else {
                err.print(buf.toString());
                err.flush();
            }
        } finally {
            System.setErr(err);
        }
    }
 ```
如果只有slf4j，而没有logback，那么`LoggerFactory.getILoggerFactory() instanceof NOPLoggerFactory`就会为true，抛出NoClassDefFoundError。
如果连slf4j本身都没有呢？那么运行到`LoggerFactory.getLoggerFactory()`就已经抛出异常了，因为找不到这个LoggerFactory类。
 
## 4.2 检测Log4J
Log4J的检测很简单，很直接，直接在`newInstance()`方法里加载`org.apache.log4j.Logger` 类，如果加载不到，直接抛异常，然后转而直接使用JDK Logging。

## 4.3 其他

Netty的内部日志机制也自定义了日志打印级别 `InternalLogLevel `, 面临日志打印级别的兼容性问题
比如Netty的DEBUG将会对应到JDK的FINE，以此做到级别的对应关系和兼容性。

日志的layout或者appender，则没有自己定义

SLF4J的Logger会有这样一种打日志的方式，采用占位的方式，举个例子：、
·`logger.info("Hello, I m {}, I m the president of {}"，"Obama"，"America");`
{}大括号是一个占位符，其内容将会被后面的参数所代替

JDK Logging并不支持这种占位的日志打印方式:
Netty又自己搞了一下:io.netty.util.internal.logging.MessageFormatter