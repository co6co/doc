---
layout: post
title: Gradle
subtitle:
date:       2023-02-01 11:51:58
categories: [andriod]
tags: [andriod,Gradle]
---


# Gradle
是一个非常先进的项目构建工具，
它使用了一种基于Groovy的领域特定语言（DSL）来进行项目设置，
摒弃了传统基于XML（如Ant和Maven）的各种烦琐配置

项目中有两个`build.gradle`文件，一个是在最外层目录下的，一个是在app目录下的
这两个文件对构建android项目都起到了至关重要的作用
最外层中的
```
buildscript {
    ext.kotlin_version = '1.3.71'
	//代码仓库
    repositories {
        google() //Google自家的 扩展依赖库
        jcenter() //包含的大多是一些第三方的开源库
        
    }
    dependencies {
		//Gradle插件
        classpath 'com.android.tools.build:gradle:3.6.0-rc01'
		//Kotlin插件
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        jcenter()
        
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}

```

下app目录下的build.gradle文
```
//应用程序模块 或者  com.android.library表示这是一个库模块
apply plugin: 'com.android.application'

//用Kotlin来开发Android项目，
//那么第一个插件就是必须应用的。
//而第二个插件帮助我们实现了一些非常好用的Kotlin扩展功能
apply plugin: 'kotlin-android'
apply plugin: 'kotlin-android-extensions'

android {
    compileSdkVersion 29   //指定项目的编译版本
    buildToolsVersion "29.0.3" //构建工具的版本

    defaultConfig {
		//应用的唯一标识符
        applicationId "top.co6co.firstapp"
        minSdkVersion 21  //最低兼容的Android系统版本
        targetSdkVersion 29  //该目标版本上已经做过了充分的测试
        versionCode 1 //指定项目的版本号
        versionName "1.0" //版本名
		
		//在当前项目中启用JUnit测试，
		//你可以为当前项目编写测试用例，以保证功能的正确性和稳定性
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }
	
	//用于指定生成安装文件的相关配置
    buildTypes {
		//一个是debug，一个是release
        release {
			//是否对项目的代码进行混淆
            minifyEnabled false
			//指定混淆时使用的规则文件 第一个：<Android SDK>/tools/proguard，第二个在当前项目的根目录下的
			//通用的混淆规则,特有的混淆规则
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

}

//本地依赖、库依赖和远程依赖
//本地的jar包或目录添加依赖关系，库依赖可以对项目中的库模块添加依赖关系，远程依赖则可以对jcenter仓库上的开源
dependencies {
	//一个本地依赖声明
	//libs目录下所有.jar后缀的文件都添加到项目的构建路径中
    implementation fileTree(dir: 'libs', include: ['*.jar'])
	//首先检查一下本地是否已经有这个库的缓存，如果没有的话则会自动联网下载，然后再添加到项目的构建路径
中
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation 'androidx.appcompat:appcompat:1.0.2'
    implementation 'androidx.core:core-ktx:1.0.2'
    implementation 'androidx.constraintlayout:constraintlayout:1.1.3'
	
	//声明测试用例库
    testImplementation 'junit:junit:4.12'
    androidTestImplementation 'androidx.test.ext:junit:1.1.1'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.2.0'
}
//至于库依赖声明这里没有用到，它的基本格式是implementation project后面加上要
依赖的库的名称，比如有一个库模块的名字叫helper，那么添加这个库的依赖关系只需要加入
implementation project(':helper')这句声明即可。

```

