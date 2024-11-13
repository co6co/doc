---
layout: post
title: spring boot
subtitle:
date:       2021-07-09 10:28:57
categories: [JAVA]
tags: [JAVA,spring boot]
---



# 1.简介
·`spring-boot-dependencies` Spring Boot的版本仲裁中心

 `启动器` 更能场景  --抽象--> 场景启动器 （引入starter，那么相关的场景的所有依赖都会导入进项目中）
	 `spring-boot-starter-web` 依赖，会自动添加 `Tomcat` 和` Spring MVC` 的依赖 ,又引入了`spring-boot-starter-tomcat`
 
 # 2. 注解
 ##　2.1 @SpringBootConfiguration
	是一个 `Configuration`配置类
	- Spring Boot的配置类
	- 标注在某个类上，表示这是一个Spring Boot的配置类
	
## 2.2 @EnableAutoConfiguration
	- 开启自动配置功能
	- Spring Boot帮助自动配置（以前使用Spring需要配置）； 
	
	`EnableAutoConfigurationImportSelector`： 导入哪些组件的选择器，将所有需要导入的组件以全类名的方式返回，这些组件就会被添加到容器中。
	SpringBoot启动从`类路径`下 `META-INF/spring.factories`中获取`EnableAutoConfiguration`指定的值，
	并将这些值作为自动配置类导入到容器中，自动配置类就会生效，最后完成自动配置工作。
	
	```
	@AutoConfigurationPackage
	@Import(EnableAutoConfigurationImportSelector.class)
	public @interface EnableAutoConfiguration {}
	```

## 2.3 @AutoConfigurationPackage
 默认将`主配置类`(`@SpringBootApplication`)所在的`包`及其`子包`里面的所有组件扫描到`Spring容器`中
	``` 
	@Import(AutoConfigurationPackages.Registrar.class)
	public @interface AutoConfigurationPackage {}
	```
# 3. Spring容器


