---
layout: post
title: HTML5+
subtitle:
date:       2021-04-08 12:04:55
categories: [uni-app]
tags: [uni-app,HTML5+]
---


uni-app App 端`内置 HTML5+ 引擎`，让 js 可以直接调用丰富的`原生能力`。
`小程序`及 `H5 `等平台是`没有 HTML5+ `扩展规范的
在普通的 H5+ 项目中，需要使用 `document.addEventListener` 监听原生扩展的事件。
uni-app 中，没有 document。可以使用 plus.globalEvent.addEventListener 来实现
```js
// #ifdef APP-PLUS
// 监听设备网络状态变化事件
plus.globalEvent.addEventListener('netchange', function(){});
// #endif
```
同理:
在 uni-app 中使用 Native.js 时，一些 Native.js 中对于原生事件的监听同样需要按照上面的方法去实现。

uni-app 已将常用的组件、JS API 封装到框架中，开发者按照 uni-app 规范开发即可保证多平台兼容，大部分业务均可直接满足。
条件编译：
\#ifdef[#ifndef] %PLATFORM%：平台名称
- APP-PLUS #App 平台
- H5 #App 平台
- MP-WEIXIN 微信小程序 `#ifdef H5 || MP-WEIXIN`

|值|平台|
|---:|---|
|APP-PLUS	|App|
|APP-PLUS-NVUE	|App nvue|
|H5|	H5|
|MP-WEIXIN	|微信小程序|
|MP-ALIPAY	|支付宝小程序|
|MP-BAIDU	|百度小程序|
|MP-TOUTIAO	|字节跳动小程序|
|MP-QQ	|QQ小程序|
|MP	|微信小程序/支付宝小程序/百度小程序/字节跳动小程序/QQ小程序|
支持的文件 :
`.vue,.js,.css,pages.json`各预编译语言文件，如：.scss、.less、.stylus、.ts、.pug
