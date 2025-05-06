---
layout: post
title:  ZLMediaKit

header-img: 
date:   2025-05-06 10:15:01
modify: 2025-05-06 10:15:01
categories: [开发,编译]
tags: [ZLMediaKit,流媒体 ]
---
参考：https://juejin.cn/post/7322010571360370703
# 1. 获取源码并初始化子模块
git clone --depth 1 https://gitee.com/xia-chu/ZLMediaKit
cd ZLMediaKit
# 初始化并更新子模块
git submodule update --init

# 2. 安装vs
记得选中 使用C++进行Linux和嵌入式开发+ 适用于Linux的远程文件资源管理器

# 3. cmake-3.24.2-windows-x86_64.zip
# 4. 安装OpenSSL (完整版) 【不能用轻量版】
环境变量：OPenssl-Win64 
环境变量：OPenssl-Win64\bin 
环境变量：OPenssl-Win64\lib

变量名：OPENSSL_ROOT_DIR，变量值：C:\OpenSSL-Win64（根据实际安装路径修改）
变量名：OPENSSL_CRYPTO_LIBRARY，变量值：C:\OpenSSL-Win64\lib\libcrypto.lib
变量名：OPENSSL_INCLUDE_DIR，变量值：C:\OpenSSL-Win64\include

openssl version，出现版本信息即代表安装成功
如果出现版本对应不上的情况，是因为其他软件安装了 OpenSSL 并配了环境变量造成冲突，不需要管它，只要配了环境变量cmake就能识别

# 5 编译 libsrtp 
libsrtp-2.4.2.zip
新建build和install文件夹，用于存放构建和make install后的srtp文件
打开D:\software\cmake-3.24.2-windows-x86_64\bin下的cmake-gui.exe文件 设置strp源码路径和build路径，并点击Configure设置生成器

#  
勾选BUILD_SHARED_LIBS（关键，勾选后才会生成dll）；
点击CMAKE_INSTALL_PREFIX后的路径修改为刚才新建的install文件夹；
然后勾选ENABLE_OPENSSL；
最后点击Generate生成。

## 检查cmack 文件是否正确
```
cmake -DBUILD_TYPE=Debug -P cmake_install.cmake
```


# 6. build 运行
安装 Win64OpenSSL-3_5_0.exe 环境变量 
srtp2
vcruntime140d.dll  https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170


# 7. 可能用到的项目
https://zlmediakit.github.io/ZLMediaKit/