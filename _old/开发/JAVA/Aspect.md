---
layout: post
title: Aspect
subtitle:
date:       2022-12-15 10:43:42
categories: [JAVA]
tags: [JAVA,Aspect]
---


# execution
```
execution (<修饰符>? <返回类型><方法名>(<参数>)<异常>?)
例如：
execution (public * *(..))  #* 返回值类型；
							#* 方法名
							#.. 任意参数
execution (public * *To(..)) # 以To结尾的方法名

execution (* com.bao.Interface.*(..)) #接口中所有的方法
execution (* com.bao.Interface+.*(..)) #接口及实现类中所有的方法


execution (* com.bao.*(..))  #包中所有的类
execution (* com.bao...**(..))  #包及子包中所有的类
							
```

# within 
指定某些`类(包)`的`全部方法`执行
```
within (com.xyz.service.*) # 包中所有的方法，不包含子包
within (com.xyz.service..*) #包中所有的方法，包含子包
within (UserDao+) #接口所有实现类中的实现方法

```
# @within
匹配被代理的目标对象对应的类型或其父类型拥有指定的注解的,
但只有在调用拥有指定注解的类上的方法时才匹配。
```
#匹配被调用的方法声明的类上拥有RestController注解
@within(org.springframework.web.bind.annotation.RestController)

```
# this
Spring Aop是基于代理的，this就表示代理对象；
this(type) 当生成的代理对象可以转换为type指定的类型时则表示匹配。
基于JDK接口的代理和基于CGLIB的代理生成的代理对象是不一样的。

# target
target表示被代理的目标对象。当被代理的目标对象可以被转换为指定的类型时则表示匹配。
```
#匹配被代理的目标对象能够转换为UserService类型的所有方法的外部调用
target(com.elim.spring.aop.service.UserService) 

```
this 和 target 的不同点:
- this作用于代理对象，target作用于目标对象
- this表示目标对象被代理之后生成的代理对象和指定的类型匹配会被拦截，匹配的是代理对象
- target表示目标对象和指定的类型匹配会被拦截，匹配的是目标对象
 
# @target
匹配当被代理的目标对象对应的类型及其父类型上拥有指定的注解
 `@target(com.elim.spring.support.MyAnnotation) `目标对象中包含指定注解
# args 用来匹配方法参数的
```
args() #匹配任何不带参数的方法 
args(java.lang.String) #匹配任何只带一个String类型参数的方法 
args(..) #匹配带任意参数的方法 
args(java.lang.String,..) #匹配带任意个参数，但是第一个参数的类型是String的方法 
args(..,java.lang.String) #匹配带任意个参数，但是最后一个参数的类型是String的方法 
 
```

# @args 方法参数所属的类型上有指定的注解 
`@args(com.elim.spring.support.MyAnnotation)`
匹配方法参数类型上拥有MyAnnotation注解的方法调用。
如我们有一个方法add(MyParam param)接收一个MyParam类型的参数，
而MyParam这个类是拥有注解MyAnnotation 
 
# bean
```
bean(*Service) # 匹配指定名结尾的bean 中的所有方法
bean(*Service) && within (com.xyz.service.*)



```
# @annotation
匹配方法上拥有指定注解的情况
```
@annotation(io.swagger.annotations.ApiOperation)
```

# 备注
Pointcut定义时，还可以使用&&、||、! 这三个运算
注意不能直接new，直接new的对象不会纳入ioc管理，这样就不会被aop识别