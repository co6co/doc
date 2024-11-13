---
layout: post
title: SrpingWeb安全
subtitle:
date:       2021-09-26 10:01:01
categories: [JAVA]
tags: [JAVA,SrpingWeb安全]
---


[TOPC](Spring Security )

# 1. Web Security 与  Http Security
过滤器名字叫`springSecurityFilterChain`类型是`FilterChainProxy`
核心过滤器里面是`过滤器链`（列表），过滤器链的`每个元素`都是`一组URL`对应`一组过滤器`

`WebSecurity`  建造者	创建`FilterChainProxy`过滤器，
`HttpSecurity` 建造者   创建`FilterChainProxy`中的一个`SecurityFilterChain`

通过`配置器`对`建造者`进行配置

继承`WebSecurityConfigurerAdapter`，重写几个`configure()`方法
WebSecurityConfigurerAdapter就是`Web安全配置器`的适配器对象

建造者:`build()`; `doBuild()`; `init()`; `configure()`; `performBuild()`;
配置器:`init()`; `config()`;

#2 WebSecurityConfiguration 配置类
## 2.1 `setFilterChainProxySecurityConfigurer()` #创建了WebSecurity建造者对象
	- @Value("#{}") 是`SpEl表达式`
	  通常用来`获取bean的属性`或者`调用bean的某个方法`。
	  `@Value("#{@autowiredWebSecurityConfigurersIgnoreParents.getWebSecurityConfigurers()}"`
	  得到所有实现 `WebSecurityConfigurerAdapter`的配置类实例  
	   
	  `多个WebSecurityConfigurerAdapter配置器适配器的子类，会产生多个SecurityFilterChain过滤器链实例`
	  `Spring Security Oauth2`就是用上面方法做的
	   
	- 创建 websecurity对象
	- 对 `webSecurityConfigurers` 排序 有相同排序抛出异常
	- 接排序后的结果`apply()`到 websecurity 中 `List<SecurityConfigurer<O, B>> configurersAddedInInitializing`

## 2.2 `springSecurityFilterChain()` #调用`WebSecurity.build()`，建造出`FilterChainProxy`过滤器对象
	-如果我们创建的`SecurityConfig`  未被Spring扫描到 Spring 会 new 出一个`WebSecurityConfigureAdapter`对象
	- WebSecurity.Build 创建 `FilterChainProxy`<--`springSecurityFilterChain`
	```
	this.buildState = AbstractConfiguredSecurityBuilder.BuildState.INITIALIZING;
	this.beforeInit();
	this.init();
	this.buildState = AbstractConfiguredSecurityBuilder.BuildState.CONFIGURING;
	this.beforeConfigure();
	this.configure();
	this.buildState = AbstractConfiguredSecurityBuilder.BuildState.BUILDING;
	O result = this.performBuild();
	this.buildState = AbstractConfiguredSecurityBuilder.BuildState.BUILT;
	return result;
	``` 
	`WebSecurityConfigurerAdapter`是一个`安全配置器`，建造者在`performBuild()`之前循环调用安全配置器的`init()`;`configure();`方法，
	 然后创建`HttpSecurity`并放入自己的`securityFilterChainBuilders`里。
	 `WebSecurityConfigurerAdapter.init(WebSecurity web) `
## 2.3 ServletContext如何拿到FilterChainProxy
Bean都是存在Spring的`Bean工厂`里的，而且在Web项目中Servlet、Filter、Listener都要放入`ServletContext`中
`ServletContainerInitializer`接口提供了一个`onStartup()`方法，用于`在Servlet容器启动时动态注册一些对象到ServletContext`中。

为了支持可以`不使用web.xml`。提供了ServletContainerInitializer，它可以通过`SPI机制`，
	- 当启动`web容器`的时候
	- 自动到添加的相应`jar包`下找到`META-INF/services`下以ServletContainerInitializer的全路径名称命名的文件，
	  它的内容为`ServletContainerInitializer实现类`的`全路径`，将它们实例化。
	  ```
	  @HandlesTypes({WebApplicationInitializer.class})
	  public class SpringServletContainerInitializer
	  ```
	- `Servlet容器`在调用`onStartup()`方法时，会以Set集合的方式`注入WebApplicationInitializer的子类（包括接口，抽象类）`。
	  然后会依次调用`WebApplicationInitializer`的实现类的`onStartup`方法，
	  从而起到启动web.xml相同的作用（添加servlet，listener实例到ServletContext中）。
	  
	-`Spring Security`中的`AbstractSecurityWebApplicationInitializer`就是`WebApplicationInitializer`的抽象子类.
	  当执行到下面的onStartup()方法时，会调用`insertSpringSecurityFilterChain()`
	  将类型为`FilterChainProxy`名称为springSecurityFilterChain的过滤器对象用`DelegatingFilterProxy`包装，然后注入ServletContext
	- 请求到达的时候进入`FilterChainProxy`的`dofilter()`方法内部，
	  遍历所有的`SecurityFilterChain`，对匹配到的url，则一一调用SecurityFilterChain中的filter做认证或授权。
	  
# 3. HttpSecurity 
  创建的MySecurityConfig继承了`WebSecurityConfigurerAdapter` 就是用来`创建过滤器链`，
 `重写`的configure(HttpSecurity http)用来`配置HttpSecurity`
  configure(HttpSecurity http)方法内的配置最终内容主要是`Filter的创建`
  ```
  http.authorizeRequests()			#ExpressionUrlAuthorizationConfigurer
  http.formLogin() 					#FormLoginConfigurer
  http.httpBasic()					#HttpBasicConfigurer 
 ```
 SecurityConfigurer 是配置器基类，`configure()`为子类 创建各个过滤器 ，并将过滤器`添加进HttpSecurity`
 
 ## 3.1 过滤器 `UsernamePasswordAuthenticationFilter`
 `AbstractAuthenticationProcessingFilter`中的`attemptAuthentication`方法。这个方法会调用认证管理器`AuthenticationManager`去认证。
 `doFilter() `判断请求是否需要认证  
  `httpSecurity.formLogin().permitAll()`
### 3.1.1 认证管理器AuthenticationManager
  ProviderManager默认实现， 提供不同的`AuthenticationProvider`实现类，可以通过多种方式进行认证
  - `authenticate(Authentication authentication)`遍历providers
  - 调用`provider.authenticate()` 尝试认证
  
  我们可以实现`AuthenticationProvider接口`，重写authenticate()方法
## 3.2 BasicAuthenticationFilter
  header里头有`Authorization`，而且`value`是`以Basic开头`的，则走`BasicAuthenticationFilter`
  提取参数构造`UsernamePasswordAuthenticationToken`进行认证，成功则填充`SecurityContextHolder的Authentication`
## 3.3 AnonymousAuthenticationFilter
为匿名的用户，填充`AnonymousAuthenticationToken`到`SecurityContextHolder的Authentication`

## 3.4 授权过滤器 AbstractSecurityInterceptor
 默认的过滤器`FilterSecurityInterceptor` 一般直接`继承这个过滤器或者父类`，自定义一个`AuthorizeSecurityInterceptor`。
 为了注入自定义的`授权管理器`AccessDecisionManager、和`权限元数据`FilterInvocationSecurityMetadataSource

FilterSecurityInterceptor是在`WebSecurityConfigurerAdapter.init()`里配置的

`FilterSecurityInterceptor.doFilter()`会调用`super.beforeInvocation(fi)`方法，内部调用授权管理器做授权

自定义的AuthorizeSecurityMetadataSource实现了`FilterInvocationSecurityMetadataSource` 重写`getAttributes()`可以根据url获取对应的`角色列表`
自定义的AuthorizeAccessDecisionManager实现了`AccessDecisionManager`，重写`decide()` 来判断当前用户是否有`此url的权限`

框架默认的`AccessDecisionManager`通过`投票决策`的方式来授权
- AffirmativeBased (spring security默认使用)
  只要(`ACCESS_GRANTED=1`）>1票，则直接判为通过。
  如果`没有投通过票`且`反对（ACCESS_DENIED=-1）票`>=1，则直接判为不通过。
- ConsensusBased（少数服从多数）
  通过的票数大于反对的票数则判为通过;
  通过的票数小于反对的票数则判为不通过;
  通过的票数和反对的票数相等，则可根据配置`allowIfEqualGrantedDeniedDecisions`（默认为true）进行判断是否通过。
- UnanimousBased（反对票优先）
  无论多少投票者投了多少通过（ACCESS_GRANTED）票，
  只要有反对票（ACCESS_DENIED），那都判为不通过;
  如果没有反对票且有投票者投了通过票，那么就判为通过.

## 3.5 ExceptionTranslationFilter
  用来捕获处理`spring security`抛出的异常，异常主要来源于`FilterSecurityInterceptor`
  


#  CglibSubclassingInstantiationStrategy

HttpSecurity : AbstractConfiguredSecurityBuilder

HttpSecurity -->DefaultSecurityFilterChain
^
1
HttpSecurityConfiguration--> SimpleInstantiationStrategy <-CglibSubclassingInstantiationStrategy

GenericApplicationContext-->DefaultListableBeanFactory>>

# 4. HttpSecurityConfiguration
加载方式`@EnableWebSecurity`
```
@Import({WebSecurityConfiguration.class, SpringWebMvcImportSelector.class, OAuth2ImportSelector.class, HttpSecurityConfiguration.class})

```
## 4.1 `authenticationManager()`
去获取容器中的一个`AuthenticationManager`实例,未能获得 `authenticationConfiguration` 获取

## 4.2 核心方法httpSecurity()
```
 @Bean(HTTPSECURITY_BEAN_NAME)
@Scope("prototype")
HttpSecurity httpSecurity() throws Exception 
```
## private Map<Class<?>, Object> createSharedObjects()
将ApplicationContext包装起来供HttpSecurity使用


`setObjectPostProcessor(ObjectPostProcessor<Object> objectPostProcessor)`

Spring容器 `setApplicationContext(ApplicationContext context)`

构建ProviderManager的一个配置类 `setAuthenticationConfiguration(AuthenticationConfiguration authenticationConfiguration)`
鉴权对象，这里注入的是ProviderManager的一个实例: `void setAuthenticationManager(AuthenticationManager authenticationManager)`


 

 