---
layout: post
title: SpringWebFlux
subtitle:
date:       2022-12-27 15:25:52
categories: [JAVA]
tags: [JAVA,SpringWebFlux]
---


# 2. WebFlux 组件介绍
## 2.1 HttpHandler
一个简单的处理请求和相应的抽象，用户适配不同HTTP服务器的API
|Server Name|Bean name|
|--|--|
|Reactor Netty|ReactorHttpHandlerAdaper|
|Undertor|UndertowHttpHandlerAdapter|
|Tomcat|TomcatHttpHandlerAdapter|
|Jetty|JettyHttpHandlerAdapter|

## 2.2 WebHandler
一个用于处理业务请求抽象接口，定义了一系列处理行为：
|Bean Name| Explanation|
|--|--|
|DispatcherHandler|请求的总控制器，类似于WebMVC中的DispatcherServlet|
|FilteringWebHandler|通过WebFilter进行过滤处理的类，类似于Servlet中的Filter|
|ExceptionHandlingWebHandler|针对于异常的处理类|
|ResourceWebHandler|用于静态资源请求的处理类|

### 2.2.1 DispatcherHandler
请求处理的总控制器，实际工作是由多个可配置的组件来处理
|Bean Type|Explanation|
|--|--|
|HandlerMapping|将请求映射到对应的处理器，1. @RequestMapping --->RequestMappingHandlerMapping，2. 用于功能端点路由的RouterFunctionMapping，3. 用于URI路径模式和WebHandler实例的显式注册的SimpleUrlHandlerMapping|
|HandlerAdapter|帮助DispatcherHandler调用映射到请求的处理程序，而不管实际如何调用该处理程序。如：调用带注解的控制器需要解析注解。HandlerAdapter主要目的是用来解释编排处理行为，具体处理交给对应处理器处理|
|HandlerResultHandler|处理来自处理程序调用的结果，并最终确定响应。根据注解和返回来类型选择处理器，如：@ResponseBody注解的ResponseBodyResultHandler|

WebFlux 是兼容Spring MVC基于@Controller，@RequestMapping等注解的编程开发方式的，可以做到平滑切断。

## 2.3 Functional Endpoints
轻量级编程模型，基于@Controller，@RequestMapping等注解的编程模型的替代方案，提供一套函数式API用于创建Router，Handler和Filter。
调用处理组件
|HandlerMapping|HandlerAdapter|说明|
|--|--|--|
|RouterFunctionMapping|HandlerFunctinoAdapter|支持RouterFunction|
```
@Bean
public RouterFunction<ServerResponse> router(){
	return RouterFunctions.route()
			.GET("/hello/{name}", serverRequest -> {
				String name= serverRequest.pathVariable("name");
				return ServerResponse.ok().bodyValue(name);
			}).build();
}
```

## 2.4 Reactive Stream
利用Reactor来重写传统Spring MVC逻辑，其中 Flux和Mono是Reactor中两个关键概念；

Flux和Mono都实现了reactor 的Publisher接口，对消费者提供订阅接口，当有事件发生时，Flux或Mono会通过回调消费者的相应的方法来通知消费者相应的事件。这就是所谓的相应式编程默写；

# 3. 配置源码
```
WebFluxAutoConfiguration
WebFluxConfigurationSupport
ReactiveWebServerApplicationContext
HttpHandlerAutoConfiguration
TomcatReactiveWebServerFactory

```


 


