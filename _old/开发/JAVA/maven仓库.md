---
layout: post
title: maven仓库
subtitle:
date:       2021-10-21 10:18:57
categories: [JAVA]
tags: [JAVA,maven仓库]
---


# 1. Maven 仓库
[yr](https://www.cnblogs.com/qlqwjy/p/8643032.html)
当构建一个Maven项目时，首先检查pom.xml文件以确定依赖包的下载位置，执行顺序如下：

- 本地查找并获得依赖包，如果没有，执行第2步。 
- 默认中央仓库中查找并获得依赖包（http://repo1.maven.org/maven2/），如果没有，执行第3步。
- 如果在pom.xml中定义了自定义的远程仓库，那么也会在这里的仓库中进行查找并获得依赖包，如果都没有找到，那么Maven就会抛出异常。

## 1.1. 中央仓库

1、默认地址：http://repo1.maven.org/maven2/

2、以上地址还配有搜索页面：http://search.maven.org/

3、如果想要向中央仓库提交自己的依赖包[参考](http://www.cnblogs.com/EasonJim/p/6671419.html)

## 1.2. 替换中央仓库
 
### 方法 1. 配置文件 修改仓库地址
可以直接修改Mavenconf文件夹中的`setting.xml`文件，或者在`.m2`文件夹下建立一个`setting·xml`文件。

setting.xml里面有个`mirrors`节点，用来配置镜像URL。mirrors可以配置`多个mirror`，每个mirror有`id`,`name`,`url`,`mirrorOf`属性。
```
id				唯一标识一个mirror
name			貌似没多大用，相当于描述
url				官方的库地址
mirrorOf		一个镜像的替代位置，例如central就表示代替官方的中央库。
mirror			也不是按settings.xml中写的那样的顺序来查询的。所谓的第一个并不一定是最上面的那个。
```
当有id为B,A,C的顺序的mirror在mirrors节点中，maven会`根据字母排序`来指定第一个，
一定会找到A这个mirror来进行查找，当A无法连接，出现意外的情况下，才会去B查询。

在setting·xml中添加如下代码： 
```
<mirrors>  
    ...   
    <mirror>  
      <id>alimaven</id>  
      <name>aliyun maven</name>  
      <url>http://maven.aliyun.com/nexus/content/groups/public/</url>  
      <mirrorOf>central</mirrorOf>          
    </mirror>
</mirrors>
```

###　方法 2. 分别给每个项目配置不同的中央库
直接在项目的pom.xml中修改中央库的地址。如下：
```
 
<repositories>
    <repository>
        <id>alimaven</id>
        <name>aliyun maven</name>
        <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
    </repository>
</repositories>
```
## 1.2 私服
设置私服地址的方法(私服仓库不存在jar包, 私服的代理镜像下载地址并保存到私服仓库)
将jar包下载改为`从私服下载`，前提是先搭建好私服，然后从后台设置私服仓库的远程地址为阿里云的镜像地址即可:

(1)在私服的后台设置仓库的镜像地址(用于私服不存在时候从该地址下载)

![私库](./static/开发/JAVA/imgs/maven/私库.png)

(2)修改maven的settings.xml的配置文件:配置下载地址
```
  <mirrors>
    <mirror>
      <id>nexus</id>
      <name>internal nexus repository</name>
      <mirrorOf>*</mirrorOf>
      <url>http://localhost:8081/nexus/content/repositories/central/</url>
    </mirror>
  </mirrors>
  
  ```
  
(3)在eclipse也可以查看默认使用的下载地址  `http://localhost:8081/nexus/content/repositories/central/`
(4)当引入一个不存在的jar包的时候会先下载到私服的仓库地址，然后下载到本地的仓库地址


# 2. mvn 命令
## 安装 从本地jar包安装至本地仓库
```
mvn install:install-file -Dfile=I:\JAVA\works\rxtx.jar -DgroupId=gnu.io -DartifactId=rxtx -Dversion=2.1.7 -Dpackaging=jar -DgeneratePom=true

mvn help:effective-settings		# 有效配置

mvn -X							# 配置读取顺序

```
