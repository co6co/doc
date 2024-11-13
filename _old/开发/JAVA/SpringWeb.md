---
layout: post
title: SpringWeb
subtitle:
date:       2022-12-21 15:42:26
categories: [JAVA]
tags: [JAVA,SpringWeb]
---


# 1. DispatcherServlet
  继承自HttpServlet，协调组织不同组件，完成请求处理和返回响应的工作
  整个流程：
  - 1. tomcat接受请求，交由DisptcherServlet处理
  - 2. DispatcherServlet 匹配控制器中配置的影视，进行下一步处理
  - 3. ViewResolver 将ModelAndView 或 Exception 解析成View，然后View会调用render()方法，并更具ModelAndView中的数据渲染出页面；
  
# 2. Spring Boot 支持的模板
    Thymeleaf 、Freemarker、Mustanche 、Groovy Themplates
# 3. 响应式编程
‘spring-boot-starter-web’ 与 spring-boot-starter-webflux。
MVC 地址映射：@RequestMapping提供，
Handler类 用@Controller或RestController
||MVC|Flux|
|--|--|--|
|处理类|@Controller或@RestController|Handler类|
|地址映射|@RequestMapping|RouterFunction|

RouterFunction：第一参数 路径，第二个参数方法；


## 3.1 Mono和Flux
否需要获取所有 User( 这是 个集合) ，则需要将这个集合包装成 Flux<User> 。这里的单个
数据并不是指一个数据 而是指封装好的 个对象。多个数据就是多个对象。

## APO
业务分解为核心、非核心
- 核心： 
- 非核心：性能统计、日志、事务管理

#4. 监视器
## 4.1 监听ServletContext、Request、Session 作用域的创建和销毁
	```
	- ServletContextListener  监听ServeltContext;
	- HttpSessionListenner    监听Session创建事件
	- ServletRequestListener  监听ServletRequest的初始化和销毁
	
	```
## 4.2 监听 ServletContext、Request、Session作用域中的属性变化（增加/修改/删除）
	```
	- ServletContextAttributeListenner :监听Servlet上下文参数的变化
	- HttpSessionAttributelistener      ： 监听HttpSession 参数的变化
	- ServletRequestAttributeListener   :监听ServletRequest 参数的变化
	
	```
## 4.3 监听HttpSession中对象状态的改变（被绑定、解除保定、钝化、活化）
	```
	- HttpSessionBindingListener ： 监听HttpSession的绑定和解绑定；
	- HttpSessionActivationListener :监听钝化和活动的HttpSession状态改变
	
	```

# 5. 系统异常
- Error: 代表编译和系统的错误，不允许捕获。
- Exception: 标准JAVA库的方法所激发的异常，包含Runtime_Exception运行时异常和非运行异常Non_RuntimeException的子异常；
- Runtime Exception ：运行时异常；
- Non_RuntimeException: 非运行时可检测的异常，Java编译器利用分析方法或构造方法中可能产生的结果来检测程序中是否含有检测异常的处理程序，每个可能的可检测异常、方法或构造方法的throws子句必须列出该异常对应的类；
- Throw: 用户自定义异常。

# 6. 安全模块
## 6.1 验证（authentication）
Principal  - 使用者信息（人或设备等）
Spring Secutiry 支持的认证方式：Http基本认证、Http表单验证、HTTP摘要认证、OpenID和LDAP等；
认证步骤：
- 1. 用户使用密码登录
- 2. 过滤器（UsernamePasswordAuthenticationFilter） 获取到用户名、密码、然后封装成Authentication
- 3. AuthenticationManager 认证token(Authentication的实现类传递)；
- 4. Authentication认证成功，返回一个封装了用户权限信息的Authentication对象，用户的上下文信息（角色列表等）；
- 5. Authentication对象赋值给当前SecurityContext,建立这个用户的安全上下文（SecurityContextHolder.getContext().seAuthentication()）.
- 6. 用户进行一些收到访问控制机制保护的操作，访问控制机制会依据当前安全上下文信息检测这个操作所需的权限；

## 6.2. 授权（authorization）
对Web资源的保护，最好的方法是使用过滤器，对方法调用的保护，最好的办法是使用AOP;
在进行用户认证及授予权限时，也是通过各种拦截器和AOP来控制权限访问的，从而实现安全；

# 7. 核心类
## 7.1 SecurityContext 
包含正在访问系统的用户的详细信息：
- getAuthentication(): 获取当前经过身份验证的主体或身份验证的请求令牌；
- setAuthentication(): 更改或删除当前已验证的主体身份验证信息。

SecurityContext的信息是由SecurityContextHolder 来处理。

## 7.2 SecurityContextHolder
用来保存SecurityContext，最常见的是getContext()方法，用来获得当前SecurityContext.
其中定义了一序列的静态方法，这些静态方法的内部逻辑是通过SecurityContextHolder持有的SecurityContextHolderStrategy来实现的，
如clearContext()、getContext()、setContext()、createEmptyContext()。

# 8. strategy
基于ThreadLocal的ThreadLocalSecurityContextHolderStrategy来实现；
除 SecurityContext和SecurityContextHolder ，Spring Security还提供了3种类型的strategy来实现
- GlobalSecurityContextHolderStrategy: 表示全局使用同一个SecurityContext，如C/S结构的客户端；
- InheritableThreadLocalSecurityContextHolderStrategy: 使用InheritableThreadLocal来存放SecurityContext，即子线程可以使用父线程中存放的变量；
- ThreadLocalSecurityContextHolderStrategy：使用ThreadLocal来存放SecurityContext

改变方法：
- SecurityContextHolder 静态方法 setStrategyName(strategyName) 来改变需要使用的strategy
- 通过系统属性（System_PROPERTY）进行指定，其中属性名默认为：“spring.security.strategty”,属性名对应strategy的名称；

# 9. ProviderManager
维护一个认证列表，以便处理不同认证方式的认证，系统可以存在多种认证，比如：手机号、用户名密码和邮箱方式；

在认证时如果ProviderManager 的认证结果不是 null，则说明认证成功，不在进行其他方式的认证，
并且把认证的结果保存在SecurityContext中，如果不成功，则抛出错误信息 ProviderNotFoundException

#10. DaoAuthenticationProvider
是AuthenticationProvider最常用的实现，用来获取用户提交的用户名和密码，并进行正确性比对，如果正确，返回数据库中的用户信息；
- 1. 用户前台提交用户和密码
- 2. 封装成UserNamepasswordAuthenticationToken
- 3. DaoAuthenticationProvider 根据retrieveUser方法，交给additionalAuthenticationChecks 方法完成，
- 4. UsernamePasswordAuthenticationToken 和UserDetails密码的对比，如果方法没有抛出异常，则认证对比成功；
    比对密码需要用到 PasswordEncoder 和SaltSource。

# 11. UserDetails
是Spring Security 的用户实体类，包含用户名、密码、权限等信息，
UserDetailsService；

GrantedAuthority,定义了一个getAuthority()方法，返回一个字符串，表示对应权限的字符串，

### 11.1 SecurityContextPersistenceFilter 
 从SecurityContextRepository中取出用户认证信息，为了提高效率，避免每次请求都要查询认证信息，它会从Session中取出已认证的用户信息，然后将其放入SecurityContextHOlder中，以便其他Filter使用
### 11.2 WebAsyncManagerIntegrationFilter;
 集成 SecurityContext和WebAyncManager，把SecurityContext设置到异步线程，使其也能获取到用户上下文认证信息；
 ## 11.3 HanderWriterFilter
 对请求Header增加相应的信息；
 ## 11.4 CsrfFilter
 跨域请求伪造过滤器，通过客户端传过来的token 与服务器端存储的token进行对比，来判断请求的合肥性；
 ## 11.5 LogoutFilter
 匹配登出URL，匹配成功后，退出用户，并清除认证信息；
 ## 11.6 UsernamePasswordAuthenticationFilter
 登录认证过滤器，默认对 /login 的POST请求进行认证，该方法会调用AttempAuthentication，尝试获取一个Authentication认证对象，以保存认证信息
 ，然会转向下一个Filter，最好调用successfulAuthentication执行认证后的事件；
 
 ## 11.7 AnonymousAuthenticationFilter
 如果SecurityContextHolder中的认证信息为空 ，则会创建一个匿名用户到SecurityContextHOlder中
 ## 11.8 SessionManagementFilter
 持久化登录用户信息，用户信息会被保存到Sessioon、Cookie或Redis中；
 
# 12 Redis和Memcached 比较
性能都高，Memcached数据结构单一；Redis丰富的数据结构
内存：Redis2.0后增加了自己的VM特性，突破物理内存的限制；
	  Memcached 可以修改最大可用内存的大小，采用LRU算法；
可用性：Redis以来客户端来实现分布式读写，主从复制时，每次从节点重新连接主节点都以来这个快照，无增量复制，Redis不支持分片功能，依赖程序设置一致的散列机制；
Memcached 采用成熟的hash或环状算法，来解决单点故障引起的抖动问题，本身美英数据冗余机制；