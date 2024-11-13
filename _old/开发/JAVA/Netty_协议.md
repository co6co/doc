---
layout: post
title: Netty_协议
subtitle:
date:       2021-11-30 09:27:00
categories: [JAVA]
tags: [JAVA,Netty_协议]
---


# 1. webSocket
从标准的HTTP或者HTTPS协议切换到WebSocket时，将会使用一种称为升级握手的机制,因此始终以HTTP/S作为开始，然后再执行升级。
这个升级动作发生的确切时刻，可能会发生在启动时，也可能会发生在请求了某个特定的URL之后。

后面将以构造聊天室为例，其结构图：
![websocket_聊天室](/static/开发/JAVA/imgs/websocket_聊天室.png)
## 1.1.HTTP请求和响应。

实现HTTP请求的组件。这个组件将提供用于访问聊天室并显示由连接的客户端发送的消息的网页。
channelRead0()方法的实现是如何转发任何目标URI为/ws的请求的
```
public class HttpRequestHandler
　　extends SimpleChannelInboundHandler<FullHttpRequest> {   ← --  扩展SimpleChannel-InboundHandler 以处理FullHttpRequest 消息
　　private final String wsUri;
　　private static final File INDEX;

　　static {
　　　　URL location = HttpRequestHandler.class
　　　　　　.getProtectionDomain()
　　　　　　.getCodeSource().getLocation();
　　　　try {
　　　　　　String path = location.toURI() + "index.html";
　　　　　　path = !path.contains("file:") ? path : path.substring(5);
　　　　　　INDEX = new File(path);
　　　　} catch (URISyntaxException e) {
　　　　　　throw new IllegalStateException(
　　　　　　　　"Unable to locate index.html", e);
　　　　}
　　}

　　 public HttpRequestHandler(String wsUri) {
　　　　this.wsUri = wsUri;
　　}

　　@Override
　　public void channelRead0(ChannelHandlerContext ctx,
　　　　FullHttpRequest request) throws Exception {
　　　　if (wsUri.equalsIgnoreCase(request.getUri())) {　  ← -- ❶如果请求了WebSocket协议升级，则增加引用计数（调用retain()方法），并将它传递给下一个ChannelInboundHandler
　　　　　　ctx.fireChannelRead(request.retain());
　　　　} else {
　　　　　　if (HttpHeaders.is100ContinueExpected(request)) {　 ← -- ❷ 处理100 Continue请求以符合HTTP1.1 规范
　　　　　　　　send100Continue(ctx);
　　　　　　}
　　　　　　RandomAccessFile file = new RandomAccessFile(INDEX, "r");　 ← -- 读取index.html
　　　　　　HttpResponse response = new DefaultHttpResponse(
　　　　　　　　request.getProtocolVersion(), HttpResponseStatus.OK);
　　　　　　response.headers().set(
　　　　　　　　HttpHeaders.Names.CONTENT_TYPE,
　　　　　　　　"text/html; charset=UTF-8");
　　　　　　boolean keepAlive = HttpHeaders.isKeepAlive(request);
　　　　　　if (keepAlive) {　 				← -- 如果请求了keep-alive，则添加所需要的HTTP头信息　 
　　　　　　　　response.headers().set(
　　　　　　　　　　HttpHeaders.Names.CONTENT_LENGTH, file.length());
　　　　　　　　response.headers().set( HttpHeaders.Names.CONNECTION,
　　　　　　　　　　HttpHeaders.Values.KEEP_ALIVE);
　　　　　　}
　　　　　　ctx.write(response);   			← -- ❸将HttpResponse写到客户端
　　　　　　if (ctx.pipeline().get(SslHandler.class) == null) {   ← -- ❹将index.html写到客户端
　　　　　　　　ctx.write(new DefaultFileRegion(
　　　　　　　　　　file.getChannel(), 0, file.length()));
　　　　　　} else {
　　　　　　　　ctx.write(new ChunkedNioFile(file.getChannel()));
　　　　　　}
　　　　　　ChannelFuture future = ctx.writeAndFlush(   ← -- ❺写LastHttpContent并冲刷至客户端
　　　　　　　　LastHttpContent.EMPTY_LAST_CONTENT);
　　　　　　if (!keepAlive) {   						← -- ❻如果没有请求keep-alive，则在写操作完成后关闭Channel
　　　　　　　　future.addListener(ChannelFutureListener.CLOSE);
　　　　　　}
　　　　}
　　}

　　private static void send100Continue(ChannelHandlerContext ctx) {
　　　　FullHttpResponse response = new DefaultFullHttpResponse(
　　　　　　HttpVersion.HTTP_1_1, HttpResponseStatus.CONTINUE);
　　　　ctx.writeAndFlush(response);
　　}

　　@Override
　　public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause)
　　　　throws Exception {
　　　　cause.printStackTrace();
　　　　ctx.close();
　　}
}
```

如果该HTTP请求指向了地址为/ws的URI，那么HttpRequestHandler将调用FullHttp-Request对象上的retain()方法，
并通过调用fireChannelRead(msg)方法将它转发给下一个ChannelInboundHandler❶。之所以需要调用retain()方法，
是因为调用channelRead()方法完成之后，它将调用FullHttpRequest对象上的release()方法以释放它的资源。

如果客户端发送了HTTP 1.1的HTTP头信息Expect: 100-continue，那么Http-RequestHandler将会发送一个100 Continue❷响应。
在该HTTP头信息被设置之后，Http-RequestHandler将会写回一个HttpResponse❸给客户端。
这不是一个FullHttp-Response，因为它只是响应的第一个部分。此外，这里也不会调用writeAndFlush()方法，在结束的时候才会调用。

如果不需要加密和压缩，那么可以通过将index.html❹的内容存储到DefaultFile-Region中来达到最佳效率。这将会利用零拷贝特性来进行内容的传输。
为此，你可以检查一下，是否有SslHandler存在于在ChannelPipeline中。否则，你可以使用ChunkedNioFile。

HttpRequestHandler将写一个LastHttpContent❺来标记响应的结束。
如果没有请求keep-alive❻，那么HttpRequestHandler将会添加一个ChannelFutureListener到最后一次写出动作的ChannelFuture，并关闭该连接。
在这里，你将调用writeAndFlush()方法以冲刷所有之前写入的消息。

## 1.2 WebSocket帧
WebSocket以帧的方式传输数据，每一帧代表消息的一部分。一个完整的消息可能会包含许多帧。
由IETF发布的WebSocket RFC，定义了`6种帧`，Netty为它们每种都提供了一个POJO实现。

|帧　类　型|描　　述|
|--|:--|
|BinaryWebSocketFrame		|包含了二进制数据|
|TextWebSocketFrame			|包含了文本数据|
|ContinuationWebSocketFrame |包含属于上一个BinaryWebSocketFrame或TextWebSocket- Frame的文本数据或者二进制数据|
|CloseWebSocketFrame		|表示一个CLOSE请求，包含一个关闭的状态码和关闭的原因|
|PingWebSocketFrame			|请求传输一个PongWebSocketFrame|
|PongWebSocketFrame			|作为一个对于PingWebSocketFrame的响应被发送|

Netty提供了WebSocketServerProtocolHandler来处理其他类型的帧。

TextWebSocketFrame的ChannelInboundHandler，其还将在它的ChannelGroup中跟踪所有活动的WebSocket连接。
```
public class TextWebSocketFrameHandler
　　extends SimpleChannelInboundHandler<TextWebSocketFrame> {   ← --  扩展SimpleChannelInboundHandler，并处理TextWebSocketFrame 消息
　　private final ChannelGroup group;

　　public TextWebSocketFrameHandler(ChannelGroup group) {
　　　　this.group = group;
　　}

　　@Override
　　public void userEventTriggered(ChannelHandlerContext ctx,　 ← --  重写userEventTriggered()方法以处理自定义事件
　　　　Object evt) throws Exception {
　　　　if (evt == WebSocketServerProtocolHandler
　　　　　　.ServerHandshakeStateEvent.HANDSHAKE_COMPLETE) {
　　　　　　ctx.pipeline().remove(HttpRequestHandler.class);   ← --  如果该事件表示握手成功，则从该Channelipeline中移除Http-RequestHandler，因为将不会接收到任何HTTP 消息了
　　　　　　group.writeAndFlush(new TextWebSocketFrame(   ← --  ❶通知所有已经连接的WebSocket 客户端新的客户端已经连接上了
　　　　　　　　 "Client " + ctx.channel() + " joined"));  ← -- ❷将新的WebSocket Channel添加到ChannelGroup 中，以便它可以接收到所有的消息
　　　　　 group.add(ctx.channel());　 
　　　　} else {
　　　　　　super.userEventTriggered(ctx, evt);
　　　 }
　　 }

　　 @Override
　　 public void channelRead0(ChannelHandlerContext ctx,
　　　　 TextWebSocketFrame msg) throws Exception {
　　　　 group.writeAndFlush(msg.retain());   ← -- ❸增加消息的引用计数，并将它写到ChannelGroup 中所有已经连接的客户端
　　}
}

```

只有一组非常少量的责任。当和新客户端的WebSocket握手成功完成之后❶，它将通过把通知消息写到ChannelGroup中的所有Channel来通知所有已经连接的客户端，然后它将把这个新Channel加入到该ChannelGroup中❷。
如果接收到了TextWebSocketFrame消息❸，TextWebSocketFrameHandler将调用TextWebSocketFrame消息上的retain()方法，并使用writeAndFlush()方法来将它传输给ChannelGroup，以便所有已经连接的WebSocket Channel都将接收到它。

和之前一样，对于retain()方法的调用是必需的，因为当channelRead0()方法返回时，TextWebSocketFrame的引用计数将会被减少。由于所有的操作都是异步的，因此，writeAnd-Flush()方法可能会在channelRead0()方法返回之后完成，而且它绝对不能访问一个已经失效的引用。

因为Netty在内部处理了大部分剩下的功能，所以现在剩下唯一需要做的事情就是为每个新创建的Channel初始化其ChannelPipeline。为此，我们将需要一个ChannelInitializer。


## 1.3. 初始化ChannelPipeline
```
public class ChatServerInitializer extends ChannelInitializer<Channel> {   ← --  扩展了ChannelInitializer
　　private final ChannelGroup group;

　　public ChatServerInitializer(ChannelGroup group) {
　　　　this.group = group;
　　}

　　@Override
　　protected void initChannel(Channel ch) throws Exception {　  ← -- 将所有需要的ChannelHandler 添加到ChannelPipeline 中
　　　　ChannelPipeline pipeline = ch.pipeline();
　　　　pipeline.addLast(new HttpServerCodec());	//将字节解码为HttpRequest、HttpContent和LastHttpContent。并将HttpRequest、HttpContent和LastHttpContent编码为字节
　　　　pipeline.addLast(new ChunkedWriteHandler());	//写入一个文件的内容
　　　　pipeline.addLast(new HttpObjectAggregator(64 * 1024));	//将一个HttpMessage和跟随它的多个HttpContent聚合为单个FullHttpRequest或者FullHttpResponse（取决于它是被用来处理请求还是响应）。安装了这个之后，ChannelPipeline中的下一个ChannelHandler将只会收到完整的HTTP请求或响应
　　　　pipeline.addLast(new HttpRequestHandler("/ws"));		//处理FullHttpRequest（那些不发送到/ws URI的请求）
　　　　pipeline.addLast(new WebSocketServerProtocolHandler("/ws"));	//按照WebSocket规范的要求，处理WebSocket升级握手、PingWebSocketFrame、PongWebSocketFrame和CloseWebSocketFrame
　　　　pipeline.addLast(new TextWebSocketFrameHandler(group));	//处理TextWebSocketFrame和握手完成事件
　　}
}
```
WebSocketServerProtocolHandler处理了所有委托管理的WebSocket帧类型以及升级握手本身。如果握手成功，那么所需的ChannelHandler将会被添加到ChannelPipeline中，而那些不再需要的ChannelHandler则将会被移除。
 
 
Netty目前支持4个版本的WebSocket协议，它们每个都具有自己的实现类。
Netty将会根据客户端（这里指浏览器）所支持的版本 ，自动地选择正确版本的WebSocketFrameDecoder和WebSocket-FrameEncoder。

## 1.4 引导
```
public class ChatServer {
　　private final ChannelGroup channelGroup =
　　　　new DefaultChannelGroup(ImmediateEventExecutor.INSTANCE);   ← --  创建DefaultChannelGroup，其将保存所有已经连接的WebSocket Channel
　　private final EventLoopGroup group = new NioEventLoopGroup();
　　private Channel channel;

　　public ChannelFuture start(InetSocketAddress address) {  ← --  引导服务器
　　　　ServerBootstrap bootstrap = new ServerBootstrap();　
　　　　bootstrap.group(group)
　　　　　　.channel(NioServerSocketChannel.class)
　　　　　　.childHandler(createInitializer(channelGroup));
　　　　ChannelFuture future = bootstrap.bind(address);
　　　　future.syncUninterruptibly();
　　　　channel = future.channel();
　　　　return future;
　　}

　　protected ChannelInitializer<Channel> createInitializer(　  ← --  创建ChatServerInitializer
　　　　　ChannelGroup group) {
　　　　return new ChatServerInitializer(group);
　　}

　　public void destroy() {　　 ← --  处理服务器关闭，并释放所有的资源
　　　　if (channel != null) {
　　　　　　channel.close();
　　　　}
　　　　channelGroup.close();
　　　　group.shutdownGracefully();
　　}

　　public static void main(String[] args) throws Exception {
　　　　if (args.length != 1) {
　　　　　　System.err.println("Please give port as argument");
　　　　　　System.exit(1);
　　　　}
　　　　int port = Integer.parseInt(args[0]);
　　　　final ChatServer endpoint = new ChatServer();
　　　　ChannelFuture future = endpoint.start(
　　　　　　new InetSocketAddress(port));
　　　　Runtime.getRuntime().addShutdownHook(new Thread() {
　　　　　　@Override
　　　　　　public void run() {
　　　　　　　　endpoint.destroy();
　　　　　　}
　　　　});
　　　　future.channel().closeFuture().syncUninterruptibly();
　　}
}
```

## 1.5 加密
使用Netty，这不过是将一个SslHandler添加到ChannelPipeline中
```
public class SecureChatServerInitializer extends ChatServerInitializer {   ← --  扩展ChatServerInitializer以添加加密
　　 private final SslContext context;

　　public SecureChatServerInitializer(ChannelGroup group,
　　　　SslContext context) {
　　　　super(group);
　　　　this.context = context;
　　}

　　@Override
　　protected void initChannel(Channel ch) throws Exception {
　　　　super.initChannel(ch);　 ← --  调用父类的initChannel()方法
　　　　SSLEng.ine engine = context.newEngine(ch.alloc());
　　　　engine.setUseClientMode(false);
　　　　ch.pipeline().addFirst(new SslHandler(engine));  ← --  将SslHandler 添加到ChannelPipeline 中　 
　　}
}

```

调整ChatServer以使用SecureChatServerInitializer，以便在Channel-Pipeline中安装SslHandler。
```
public class SecureChatServer extends ChatServer {  ← --   SecureChatServer 扩展ChatServer 以支持加密
　　private final SslContext context;

　　public SecureChatServer(SslContext context) {
　　　　this.context = context;
　　}

　　@Override
　　protected ChannelInitializer<Channel> createInitializer(
　　　　ChannelGroup group) {
　　　　return new SecureChatServerInitializer(group, context);　  ← --   返回之前创建的SecureChatServer-Initializer 以启用加密
　　}

　　public static void main(String[] args) throws Exception {
　　　　if (args.length != 1) {
　　　　　　System.err.println("Please give port as argument");
　　　　　　System.exit(1);
　　　　}
　　　　int port = Integer.parseInt(args[0]);
　　　　SelfSignedCertificate cert = new SelfSignedCertificate();
　　　　SslContext context = SslContext.newServerContext(
　　　　cert.certificate(), cert.privateKey());

　　　　final SecureChatServer endpoint = new SecureChatServer(context);
　　　　ChannelFuture future = endpoint.start(new InetSocketAddress(port));
　　　　Runtime.getRuntime().addShutdownHook(new Thread() {
　　　　　　@Override
　　　　　　public void run() {
　　　　　　　　endpoint.destroy();
　　　　　　}
　　　　});
　　　　future.channel().closeFuture().syncUninterruptibly();
　　}
}
```


# 2.UDP广播
将演示如何使用UDP的广播能力。我们还会使用一个编码器和一个解码器来处理作为广播消息格式的POJO
单播的传输模式:发送消息给一个由唯一的地址所标识的单一的网络目的地。面向连接的协议和无连接协议都支持这种模式。
UDP提供了向多个接收者发送消息的额外传输模式:
- 多播——传输到一个预定义的主机组；
- 广播——传输到网络（或者子网）上的所有主机。

示例应用程序,通过发送能够被同一个网络中的所有主机所接收的消息来演示UDP广播的使用
使用特殊的受限广播地址或者零网络地址255.255.255.255。发送到这个地址的消息都将会被定向给本地网络（0.0.0.0）上的所有主机，而不会被路由器转发给其他的网络。

应用：
打开一个文件，通过UDP把每一行都作为一个消息广播到一个指定的端口。
接收方：指定的端口上启动一个监听程序，

广播者将监听新内容的出现，当它出现时，则通过UDP将它作为一个广播消息进行传输。
所有的在该UDP端口上监听的事件监视器都将会接收到广播消息。

数据通常由POJO表示，除了实际上的消息内容，其还可以包含配置或处理信息。
在这个应用程序中，我们将会把消息作为事件处理，并且由于该数据来自于日志文件，所以我们将它称为LogEvent。

## 2.1 广播者
```
public final class LogEvent {
　　public static final byte SEPARATOR = (byte) ':';
　　private final InetSocketAddress source;
　　private final String logfile;
　　private final String msg;
　　private final long received;

　　public LogEvent(String logfile, String msg) {   ← --  用于传出消息的构造函数
　　　　this(null, -1, logfile, msg);
　　}

　　public LogEvent(InetSocketAddress source, long received,　 ← --  用于传入消息的构造函数
　　　　String logfile, String msg) {
　　　　this.source = source;
　　　　this.logfile = logfile;
　　　　this.msg = msg;
　　　　this.received = received;
　　}


　　public InetSocketAddress getSource() {　 ← --   返回发送LogEvent 的源的InetSocketAddress
　　　　return source;
　　}

　　public String getLogfile() {　  ← -- 返回所发送的LogEvent的日志文件的名称
　　　　return logfile;
　　}

　　public String getMsg() {　  ← -- 返回消息内容
　　　　return msg;
　　}

　　public long getReceivedTimestamp() {　   ← -- 返回接收LogEvent的时间
　　　　return received;
　　}
}

```

Netty提供了大量的类来支持UDP应用程序的编写：广播者中使用
`nterface AddressedEnvelope　　<M, A extends SocketAddress>　　extends ReferenceCounted`
定义一个消息，其包装了另一个消息并带有发送者和接收者地址。其中M是消息类型；A是地址类型

`class DefaultAddressedEnvelope <M, A extends SocketAddress>　　implements AddressedEnvelope<M,A>`
提供了interface AddressedEnvelope的默认实现

`class DatagramPacketextends DefaultAddressedEnvelope<ByteBuf, InetSocketAddress>implements ByteBufHolder`
扩展了DefaultAddressedEnvelope以使用ByteBuf作为消息数据容器

`interface DatagramChannel extends Channel`
扩展了Netty的Channel抽象以支持UDP的多播组管理

`class NioDatagramChannnel extends AbstractNioMessageChannel implements DatagramChannel`
定义了一个能够发送和接收Addressed- Envelope消息的Channel类型

Netty的DatagramPacket是一个简单的消息容器，DatagramChannel实现用它来和远程节点通信。

要将LogEvent消息转换为DatagramPacket，我们将需要一个编码器。但是没有必要从头开始编写我们自己的。我们将扩展Netty的MessageToMessageEncoder
```
public class LogEventEncoder extends MessageToMessageEncoder<LogEvent> {
　　private final InetSocketAddress remoteAddress;

　　public LogEventEncoder(InetSocketAddress remoteAddress) {   ← --  LogEventEncoder 创建了即将被发送到指定的InetSocketAddress 的DatagramPacket 消息
　　　　this.remoteAddress = remoteAddress;
　　}

　　@Override
　　protected void encode(ChannelHandlerContext channelHandlerContext,
　　　　LogEvent logEvent, List<Object> out) throws Exception {
　　　　byte[] file = logEvent.getLogfile().getBytes(CharsetUtil.UTF_8);
　　　　byte[] msg = logEvent.getMsg().getBytes(CharsetUtil.UTF_8);
　　　　ByteBuf buf = channelHandlerContext.alloc()
　　　　　　.buffer(file.length + msg.length + 1);
　　　　buf.writeBytes(file);　  ← -- 将文件名写入到ByteBuf 中
　　　　buf.writeByte(LogEvent.SEPARATOR);  ← -- 添加一个SEPARATOR 
　　　　buf.writeBytes(msg);　← -- 将日志消息写入ByteBuf 中　
　　　　out.add(new DatagramPacket(buf, remoteAddress));　← -- 将一个拥有数据和目的地地址的新DatagramPacket添加到出站的消息列表中
　　}
}
```
启动器：
```
public class LogEventBroadcaster {
　　private final EventLoopGroup group;
　　private final Bootstrap bootstrap;
　　private final File file;

　　public LogEventBroadcaster(InetSocketAddress address, File file) {
　　　　group = new NioEventLoopGroup();
　　　　bootstrap = new Bootstrap();
　　　　bootstrap.group(group).channel(NioDatagramChannel.class)   ← --  引导该NioDatagram-Channel（无连接的）
　　　　　　.option(ChannelOption.SO_BROADCAST, true)　  ← --  设置SO_BROADCAST套接字选项
　　　　　　.handler(new LogEventEncoder(address));
　　　　this.file = file;
　　}
　　public void run() throws Exception {
　　　　Channel ch = bootstrap.bind(0).sync().channel();   ← --  绑定Channel 
　　　　long pointer = 0;
　　　　for (;;) {　 ← -- 启动主处理循环　
　　　　　　long len = file.length();
　　　　　　if (len < pointer) {
　　　　　　　　// file was reset
　　　　　　　　pointer = len;　 ← -- 如果有必要，将文件指针设置到该文件的最后一个字节　 
　　　　　　} else if (len > pointer) {
　　　　　　　　// Content was added
　　　　　　　　RandomAccessFile raf = new RandomAccessFile(file, "r");
　　　　　　　　raf.seek(pointer);　 ← -- 设置当前的文件指针，以确保没有任何的旧日志被发送
　　　　　　　　String line;
　　　　　　　　while ((line = raf.readLine()) != null) {
　　　　　　　　　　ch.writeAndFlush(new LogEvent(null, -1, ← -- 对于每个日志条目，写入一个LogEvent到Channel 中
　　　　　　　　　　file.getAbsolutePath(), line));
　　　　　　　　}
　　　　　　　　pointer = raf.getFilePointer();  ← -- 存储其在文件中的当前位置　　
　　　　　　　　raf.close();
　　　　　　}
　　　　　　try {
　　　　　　　　Thread.sleep(1000);　　
　　　　　　} catch (InterruptedException e) {  ← -- 休眠1 秒，如果被中断，则退出循环；否则重新处理它
　　　　　　　　Thread.interrupted();
　　　　　　　　break;
　　　　　　}
　　　　}
　　}
　　public void stop() {
　　　　group.shutdownGracefully();
　　}

　　public static void main(String[] args) throws Exception {
　　　　if (args.length != 2) {
　　　　　　throw new IllegalArgumentException();
　　　　}

　　　　LogEventBroadcaster broadcaster = new LogEventBroadcaster(　 ← -- 创建并启动一个新的LogEventBroadcaster的实例
　　　　　　new InetSocketAddress("255.255.255.255",
　　　　　　　　Integer.parseInt(args[0])), new File(args[1]));
　　　　try {
　　　　　　broadcaster.run();
　　　　}
　　　　finally {
　　　　　　broadcaster.stop();
　　　　}
　　}
}
```

## 2.2 监视器
```
public class LogEventDecoder extends MessageToMessageDecoder<DatagramPacket> {

　　@Override
　　protected void decode(ChannelHandlerContext ctx,
　　　　DatagramPacket datagramPacket, List<Object> out) throws Exception {   ← --  获取对DatagramPacket 中的数据（ByteBuf）的引用
　　　　ByteBuf data = datagramPacket.content();　 
　　　　int idx = data.indexOf(0, data.readableBytes(),　  ← --  获取该SEPARATOR的索引
　　　　　　LogEvent.SEPARATOR);
　　　　String filename = data.slice(0, idx)　 ← --  提取文件名 
　　　　　　.toString(CharsetUtil.UTF_8);
　　　　String logMsg = data.slice(idx + 1,　 ← -- 提取日志消息　
　　　　　　data.readableBytes()).toString(CharsetUtil.UTF_8);

　　　　LogEvent event = new LogEvent(datagramPacket.sender(),   ← -- 构建一个新的LogEvent 对象，并且将它添加到（已经解码的消息的）列表中
　　　　　　System.currentTimeMillis(), filename, logMsg);
　　　　out.add(event);
　　}
}
```

```
public class LogEventHandler
　　extends SimpleChannelInboundHandler<LogEvent> {   ← --  扩展SimpleChannelInbound-Handler 以处理LogEvent 消息

　　@Override
　　public void exceptionCaught(ChannelHandlerContext ctx,
　　　　Throwable cause) throws Exception {
　　　　cause.printStackTrace();　 ← --  当异常发生时，打印栈跟踪信息，并关闭对应的Channel
　　　　ctx.close();
　　}

　　@Override
　　public void channelRead0(ChannelHandlerContext ctx,
　　　　LogEvent event) throws Exception {
　　　　StringBuilder builder = new StringBuilder();　 ← --   创建StringBuilder，并且构建输出的字符串
　　　　builder.append(event.getReceivedTimestamp());
　　　　builder.append(" [");
　　　　builder.append(event.getSource().toString());
　　　　builder.append("] [");
　　　　builder.append(event.getLogfile());
　　　　builder.append("] : ");
　　　　builder.append(event.getMsg());
　　　　System.out.println(builder.toString());　 ← --  打印LogEvent的数据 
　　}
}

```

```
public class LogEventMonitor {
　　private final EventLoopGroup group;
　　private final Bootstrap bootstrap;

　　public LogEventMonitor(InetSocketAddress address) {
　　　　group = new NioEventLoopGroup();
　　　　bootstrap = new Bootstrap();
　　　　bootstrap.group(group)   ← --  引导该NioDatagramChannel
　　　　　　.channel(NioDatagramChannel.class)
　　　　　　.option(ChannelOption.SO_BROADCAST, true)　  ← --  设置套接字选项SO_BROADCAST
　　　　　　.handler( new ChannelInitializer<Channel>() {
　　　　　　　　@Override
　　　　　　　　protected void initChannel(Channel channel)
　　　　　　　　　　throws Exception {
　　　　　　　　　　ChannelPipeline pipeline = channel.pipeline();
　　　　　　　　　　pipeline.addLast(new LogEventDecoder());　  ← --  将LogEventDecoder 和LogEventHandler 添加到ChannelPipeline 中
　　　　　　　　　　pipeline.addLast(new LogEventHandler());
　　　　　　　　}
　　　　　　} )
　　　　　　.localAddress(address);
　　}

　　public Channel bind() {
　　　　return bootstrap.bind().syncUninterruptibly().channel();　 ← -- 绑定Channel。 注意，DatagramChannel 是无连接的
　　}

　　public void stop() {
　　　　group.shutdownGracefully();
　　}

　　public static void main(String[] main) throws Exception {
　　　　if (args.length != 1) {
　　　　　　throw new IllegalArgumentException(
　　　　　　"Usage: LogEventMonitor <port>");
　　　　}
　　　　LogEventMonitor monitor = new LogEventMonitor(　  ← -- 构造一个新的LogEventMonitor
　　　　　　new InetSocketAddress(Integer.parseInt(args[0])));
　　　　try {
　　　　　　Channel channel = monitor.bind();
　　　　　　System.out.println("LogEventMonitor running");
　　　　　　channel.closeFuture().sync();
　　　　} finally {
　　　　　　monitor.stop();
　　　　}
　　}
}
```


# 3. Http
Netty的Http非常适用于`非Web容器`的场景下应用。