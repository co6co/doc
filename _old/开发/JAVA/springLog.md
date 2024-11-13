---
layout: post
title: springLog
subtitle:
date:       2021-09-30 09:36:10
categories: [JAVA]
tags: [JAVA,springLog]
---


[DOC]LOG

# 1.Spring Boot
## 1.1 Spring boot 日志
 能够使用`Logback`（默认）, `Log4J2` , `java util logging`  作为日志记录工具；
 
 使用默认 LOGBACK 
 只需在 `application.properties`或者`pplication.yml` 中配置`日志级别`即可；
 比较复杂的配置:
 `src\main\resources\logback-spring.xml`文件。
 
 SpringBoot默认扫描classpath下面的`logback.xml`、`logback-spring.xml`，所以不需要再指定`spring.logging.config`配置:
 ```
 logging:
  config: classpath:logback-spring.xml
 ```
 
 默认把日志输入到console 
 
 ## 1.2  日志级别
 
 Sping Boot 默认输出ERROR , WARN , INFO 级别的日志，
 可以通过`命令行`使能DEBUG ,TRACE级别的日志输出
 ```
 java -jar my-app.jar --debug  
 java -jar my-app.jar --trace  
 
 ```
 也可在`application.yml`配置文件相同
 
 ```
 debug=true  
#trace=true 
 ```
 
 `logging.level`日志级别 `TARCE , DEBUG , INFO , WARN , ERROR , FATAL , OFF`
可以使用root级别和package级别来控制日志的输入级别：
 
 ```
logging.level.root= WARN
#针对包进行日志级别配置
logging.level.org.springframework.security= DEBUG
logging.level.org.springframework.web= ERROR
logging.level.org.hibernate= DEBUG
logging.level.org.apache.commons.dbcp2= DEBUG 
 ```
 
## 1.3 日志文件
要把日志输入到文件中，需要配置`logging.file` 或者`logging.path`属性性，
日志达到`10M`的时候，将新建一个文件记录日志；

### 1.3.1. logging.file
`ogging.file`属性用来定义`文件名` ,也可以 `路径+文件名`
```
logging.file = mylogfile.log 		#根目录中创建
logging.file = log/mylogfile.log 	#相对根目录创建
logging.file = /log/mylogfile.log 	#绝对路径
```

### 1.3.2. logging.path
`logging.path`属性用来定义`日志文件路径`
```
`logging.path = co/logs` 	#相对根路径`co/logs/spring.log`
`logging.path = /co/logs` 	#绝对路径
```


备注：file 和 path 已经更名为：
```
file:
  name: demo_web_app.log #default name spring.log
  path: ./logs
```

## 1.4 日志样式
`logging.patter.console` 修改 `console`的日志样式
```
logging.pattern.console= %d{yyyy-MMM-dd HH:mm:ss.SSS} %-5level [%thread] %logger{15} - %msg%n
`时间，日志级别，线程名，日志名以及消息`
```
 

`logging.pattern.file` 修改  `file`的日志样式:
```
logging.level.* : 作为package（包）的前缀来设置日志级别。
logging.file :配置日志输出的文件名，也可以配置文件名的绝对路径。
logging.path :配置日志的路径。如果没有配置logging.file,Spring Boot 将默认使用spring.log作为文件名。
logging.pattern.console :定义console中logging的样式。
logging.pattern.file :定义文件中日志的样式。
logging.pattern.level :定义渲染不同级别日志的格式。默认是%5p.
logging.exception-conversion-word :.定义当日志发生异常时的转换字
PID :定义当前进程的ID
```



## 1.5 更改日志框架为 `Log4J2`
```
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter</artifactId><!--Spring-boot 任意一个 Starter-->
    <exclusions>
        <exclusion>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-logging</artifactId>
        </exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-log4j2</artifactId>
</dependency>
```

# 2. 日志模块

## 2.1. slf4j
The Simple Logging Facade for Java 即java的简单日志门面,slf4j是一系列的日志接口，并没有提供真正的实现。
为各种日志框架**提供了一个统一的界面**，使用户可以用统一的接口记录日志，
动态地决定要使用的实现框架，
比如Logback，Log4j，common-logging等框架都实现了这些接口。
## 2.2 lngback 日志模块
```
logback-core		#其它模块的基础设施
logback-classic		#地位和作用等同于 Log4J，可看作Log4J改进版，并且它实现了简单日志门面 SLF4J
logback-access		#与 Servlet容器交互的模块
```
logback-spring.xml 文件
```
<?xml version="1.0" encoding="UTF-8"?>
<!--
scan：当此属性设置为true时，配置文件如果发生改变，将会被重新加载，默认值为true。
scanPeriod：设置监测配置文件是否有修改的时间间隔，如果没有给出时间单位，默认单位是毫秒当scan为true时，此属性生效。默认的时间间隔为1分钟。
debug：当此属性设置为true时，将打印出logback内部日志信息，实时查看logback运行状态。默认值为false。
-->
<configuration scan="false" scanPeriod="60 seconds" debug="false">
    <!-- 定义日志的根目录 -->
    <property name="LOG_HOME" value="/app/log" />
    <!-- 定义日志文件名称 -->
    <property name="appName" value="springboot"></property>
    <!-- ch.qos.logback.core.ConsoleAppender 表示控制台输出 -->
    <appender name="stdout" class="ch.qos.logback.core.ConsoleAppender">
        <!--
        日志输出格式：
			%d表示日期时间，
			%thread表示线程名，
			%-5level：级别从左显示5个字符宽度
			%logger{50} 表示logger名字最长50个字符，否则按照句点分割。
			%msg：日志消息，
			%n是换行符
        -->
        <springProfile name="prod">
            <!-- configuration to be enabled when the "production" profile is not active -->
            <layout class="ch.qos.logback.classic.PatternLayout">
                <pattern>%d{yyyy-MM-dd}----- [%thread] ---- %-5level %logger{50} - %msg%n</pattern>
            </layout>
        </springProfile>
        <springProfile name="!prod">
            <!-- configuration to be enabled when the "production" profile is not active -->
            <layout class="ch.qos.logback.classic.PatternLayout">
                <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{50} - %msg%n</pattern>
            </layout>
        </springProfile>
    </appender>

    <!-- 滚动记录文件，先将日志记录到指定文件，当符合某个条件时，将日志记录到其他文件 -->
    <appender name="appLogAppender" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <!-- 指定日志文件的名称 -->
        <!--<file>${LOG_HOME}/${appName}.log</file>-->
        <file>F:/spring/spring.log</file>
        <!--
        当发生滚动时，决定 RollingFileAppender 的行为，涉及文件移动和重命名
        TimeBasedRollingPolicy： 最常用的滚动策略，它根据时间来制定滚动策略，既负责滚动也负责出发滚动。
        -->
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <!--
            滚动时产生的文件的存放位置及文件名称 %d{yyyy-MM-dd}：按天进行日志滚动
            %i：当文件大小超过maxFileSize时，按照i进行文件滚动
            -->
            <fileNamePattern>${LOG_HOME}/${appName}-%d{yyyy-MM-dd}-%i.log</fileNamePattern>
            <!--
            可选节点，控制保留的归档文件的最大数量，超出数量就删除旧文件。假设设置每天滚动，
            且maxHistory是365，则只保存最近365天的文件，删除之前的旧文件。注意，删除旧文件是，
            那些为了归档而创建的目录也会被删除。
            -->
            <MaxHistory>365</MaxHistory>
            <!--
            当日志文件超过maxFileSize指定的大小是，根据上面提到的%i进行日志文件滚动 注意此处配置SizeBasedTriggeringPolicy是无法实现按文件大小进行滚动的，必须配置timeBasedFileNamingAndTriggeringPolicy
            -->
            <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>100MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
        </rollingPolicy>
        <!-- 日志输出格式： -->
        <layout class="ch.qos.logback.classic.PatternLayout">
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [ %thread ] - [ %-5level ] [ %logger{50} : %line ] - %msg%n</pattern>
        </layout>
    </appender>

    <!--
		logger主要用于存放日志对象，也可以定义日志类型、级别
		name：表示匹配的logger类型前缀，也就是包的前半部分
		level：要记录的日志级别，包括 TRACE < DEBUG < INFO < WARN < ERROR
		additivity：作用在于children-logger是否使用 rootLogger配置的appender进行输出，
		false：表示只用当前logger的appender-ref，true：
		表示当前logger的appender-ref和rootLogger的appender-ref都有效
    -->
    <!-- hibernate logger -->
    <logger name="com.lcx" level="debug" />
    <!-- Spring framework logger -->
    <logger name="org.springframework" level="debug" additivity="false"></logger>



    <!--
    root与logger是父子关系，没有特别定义则默认为root，任何一个类只会和一个logger对应，
    要么是定义的logger，要么是root，判断的关键在于找到这个logger，然后判断这个logger的appender和level。
    -->
    <root level="info">
        <appender-ref ref="stdout" />
        <appender-ref ref="appLogAppender" />
    </root>
</configuration>
```

## 2.3 Log4J2
Log4J2是Log4J的升级，升级后修正了lokback固有框架访问的问题，改进了许多功能，
实现和接口分离，在某些关键领域比Log4更快，大多数情况与LogBack相当；
支持SLF4J和公共日志API；与Logback类型实现配置变化自动载入变更的配置，且不会丢失任何日志【Logbak配置变更自动载入可能会丢失日志事件】

### 2.3.1 log4j.xml
```
<?xml version="1.0" encoding="UTF-8"?>
<!--日志级别以及优先级排序: OFF > FATAL > ERROR > WARN > INFO > DEBUG > TRACE > ALL -->
<!--Configuration后面的status，这个用于设置log4j2自身内部的信息输出，可以不设置，当设置成trace时，你会看到log4j2内部各种详细输出-->
<!--monitorInterval：Log4j能够自动检测修改配置 文件和重新配置本身，设置间隔秒数-->
<configuration status="WARN" monitorInterval="30">
    <!--先定义所有的appender-->
    <appenders>
        <!--这个输出控制台的配置-->
        <console name="Console" target="SYSTEM_OUT">
            <!--输出日志的格式-->
            <PatternLayout pattern="[%d{HH:mm:ss:SSS}] [%p] - %l - %m%n"/>
        </console>
        <!--文件会打印出所有信息，这个log每次运行程序会自动清空，由append属性决定，这个也挺有用的，适合临时测试用-->
        <File name="log" fileName="F:/spring-Log/spring.log" append="false">
            <PatternLayout pattern="%d{HH:mm:ss.SSS} %-5level %class{36} %L %M - %msg%xEx%n"/>
        </File>
        <!-- 这个会打印出所有的info及以下级别的信息，每次大小超过size，则这size大小的日志会自动存入按年份-月份建立的文件夹下面并进行压缩，作为存档-->
        <RollingFile name="RollingFileInfo" fileName="${sys:user.home}/logs/info.log"
                     filePattern="${sys:user.home}/logs/$${date:yyyy-MM}/info-%d{yyyy-MM-dd}-%i.log">
            <!--控制台只输出level及以上级别的信息（onMatch），其他的直接拒绝（onMismatch）-->
            <ThresholdFilter level="info" onMatch="ACCEPT" onMismatch="DENY"/>
            <PatternLayout pattern="[%d{HH:mm:ss:SSS}] [%p] - %l - %m%n"/>
            <Policies>
                <TimeBasedTriggeringPolicy/>
                <SizeBasedTriggeringPolicy size="100 MB"/>
            </Policies>
        </RollingFile>
        <RollingFile name="RollingFileWarn" fileName="${sys:user.home}/logs/warn.log"
                     filePattern="${sys:user.home}/logs/$${date:yyyy-MM}/warn-%d{yyyy-MM-dd}-%i.log">
            <ThresholdFilter level="warn" onMatch="ACCEPT" onMismatch="DENY"/>
            <PatternLayout pattern="[%d{HH:mm:ss:SSS}] [%p] - %l - %m%n"/>
            <Policies>
                <TimeBasedTriggeringPolicy/>
                <SizeBasedTriggeringPolicy size="100 MB"/>
            </Policies>
            <!-- DefaultRolloverStrategy属性如不设置，则默认为最多同一文件夹下7个文件，这里设置了20 -->
            <DefaultRolloverStrategy max="20"/>
        </RollingFile>
        <RollingFile name="RollingFileError" fileName="${sys:user.home}/logs/error.log"
                     filePattern="${sys:user.home}/logs/$${date:yyyy-MM}/error-%d{yyyy-MM-dd}-%i.log">
            <ThresholdFilter level="error" onMatch="ACCEPT" onMismatch="DENY"/>
            <PatternLayout pattern="[%d{HH:mm:ss:SSS}] [%p] - %l - %m%n"/>
            <Policies>
                <TimeBasedTriggeringPolicy/>
                <SizeBasedTriggeringPolicy size="100 MB"/>
            </Policies>
        </RollingFile>
    </appenders>
    <!--然后定义logger，只有定义了logger并引入的appender，appender才会生效-->
    <loggers>
        <!--过滤掉spring和mybatis的一些无用的DEBUG信息-->
        <logger name="org.springframework" level="INFO"></logger>
        <logger name="org.mybatis" level="INFO"></logger>
        <root level="all">
            <appender-ref ref="Console"/>
            <appender-ref ref="RollingFileInfo"/>
            <appender-ref ref="RollingFileWarn"/>
            <appender-ref ref="RollingFileError"/>
        </root>
    </loggers>
</configuration>
```


