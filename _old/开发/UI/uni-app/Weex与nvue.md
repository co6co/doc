---
layout: post
title: Weex与nvue
subtitle:
date:       2021-04-08 11:24:32
categories: [uni-app]
tags: [uni-app,Weex与nvue]
---


# uni-app 使用Weex/nvue的注意事项
- uni-app 内置 基于 weex 改进的原生渲染引擎。
- vue页面，则使用webview渲染，nvue页面(native vue的缩写)，则使用原生渲染。
- nvue也可以多端编译，输出H5和小程序，但nvue的css写法受限，所以如果你不开发App，那么不需要使用nvue。

- 以往的 weex ，有个很大的问题是它只是一个`高性能的渲染器`,`没有足够的API能力`.
uni-app扩展了weex原生渲染引擎的很多排版能力

nvue的组件和API写法与vue页面一致，其内置组件还比vue页面内置组件增加了更多

# nvue在css的写法限制较多
1. 仅支持flex布局，是webview的css语法的子集。
 操作系统原生排版仅支持flex的web布局。
2. 选择器方面支持的较少，只支持简单的class="classA"。
3. class 进行绑定时只支持`数组语法`
4. 有些web的css属性在nvue里无法支持，比如背景图

# 原生渲染
uni-app在App端，支持vue页面和nvue页面混搭、互相跳转。也支持纯nvue原生渲染。
启用纯原生渲染模式，可以减少App端的包体积、减少使用时的内存占用。因为webview渲染模式的相关模块将被移除。
在`manifest.json`源码视图的"app-plus"下配置`"renderer":"native"`，即代表App端启用纯原生渲染模式。此时pages.json注册的vue页面将被忽略，vue组件也将被原生渲染引擎来渲染。

#weex 编译模式
在`manifest.json`中可以配置使用`weex编译模式`或`uni-app编译模式`。
选择weex编译模式时将不支持uni-app的组件和`js api`.比如：
weex 编译模式用<div>。uni-app 编译模式则使用<view>.
nvue页面使用uni-app模式
```manifest.json -> app-plus -> nvueCompiler ``` 取值：`[weex|uni-app]`

||weex编译模式|uni-app编译模式|
|---|---|---|
|       |weex编译模式|	uni-app编译模式||
|平台	|仅App	|所有端，包含小程序和H5|
|组件	|weex组件如div	|uni-app组件如view|
|生命周期 |	只支持weex生命周期|	支持所有uni-app生命周期|
|JS API	|weex API、uni API、Plus |API	weex API、uni API、Plus API|
|单位	|750px是屏幕宽度，wx是固定像素单位|	750rpx是屏幕宽度，px是固定像素单位|
|全局样式 |	手动引入	|app.vue的样式即为全局样式|
|页面滚动|	必须给页面套或组件|	默认支持页面滚动|

# nvue 和 vue 相互通讯
在 uni-app 中，nvue 和 vue 页面可以混搭使用。
推荐使用`uni.$on`,`uni.$emit`的方式进行页面通讯，~~旧的通讯方式（uni.postMessage及plus.webview.postMessageToUniNView）不再推荐使用。~~
```js
// 接收信息的页面
// $on(eventName, callback)  
uni.$on('page-popup', (data) => {  
    console.log('标题：' + data.title)
    console.log('内容：' + data.content)
})  

// 发送信息的页面
// $emit(eventName, data)  
uni.$emit('page-popup', {  
    title: '我是title',  
    content: '我是content'  
});
```
要在页面卸载前，使用 `uni.$off` 移除事件监听器

# vue 和 nvue 共享的变量和数据
1. vuex:自HBuilderX 2.2.5起，nvue支持vuex。这是vue官方的状态管理工具。
不支持直接引入`store`使用，可以使用`mapState、mapGetters、mapMutations`等辅助方法或者使用`this.$store`.
2. uni.storage:可以使用相同的`uni.storage`存储。这个存储是持久化的。 比如登陆状态可以保存在这里。
App端还支持`plus.sqlite`，也是共享通用的。
3. globalData:
小程序有`globalData机制`，这套机制在uni-app里也可以使用，全端通用。
```js
 export default {  
        globalData: {  
            text: 'text'  
        },  
        onLaunch: function() {  
            console.log('App Launch')  
        },  
        onShow: function() {  
            console.log('App Show')  
        },  
        onHide: function() {  
            console.log('App Hide')  
        }  
    }  
```
js中操作globalData的方式如下： `getApp().globalData.text = 'test'`
如果需要把globalData的数据绑定到页面上，可在页面的`onShow`声明周期里进行`变量重赋值`。

# BindingX
BindingX是weex提供的一种`预描述交互语法`。由原生解析BindingX规则，按此规则处理视图层的交互和动效。不再实时去js逻辑层运行和通信。
uni-app是逻辑层和视图层分离的。此时会产生两层通信成本。比如拖动视图层的元素，如果在逻辑层不停接收事件，因为通信损耗会产生不顺滑的体验。
uni-app 内置了 BindingX，可在 nvue 中使用 BindingX 完成复杂的动画效果。
2.3.4起，uni-app 编译模式可直接引用uni.requireNativePlugin('bindingx')模块，weex 模式还需使用 npm 方式引用。

nvue 里使用 HTML5Plus API并且不需要等待plus ready。
nvue 里不支持的 uni-app API:
- uni.createAnimation()//创建一个动画实例
- uni.pageScrollTo()   //将页面滚动到目标位置
- 绘画                  //canvas API使用
- uni.createIntersectionObserver() //创建并返回一个 IntersectionObserver 对象实例