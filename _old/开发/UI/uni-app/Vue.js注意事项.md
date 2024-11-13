---
layout: post
title: Vue.js注意事项
subtitle:
date:       2021-04-08 10:33:36
categories: [uni-app]
tags: [uni-app,Vue.js注意事项]
---


# 注意事项
- uni-app 在发布到H5时支持所有vue的语法；
- 发布到App和小程序时，由于平台限制，**无法实现全部vue语法**


相比Web平台uni-app 中使用差异主要集中在两个方面：
- 新增：uni-app除了支持`Vue实例的生命周期`，还支持应用`启动、页面显示等生命周期`
- 受限：相比web平台，在小程序和App端部分功能受限。

# 全局变量
- 遵循 Vue 单文件模式的开发规范

# uni-app内置基础组件
原生组件上的事件绑定，需要以 vue 的事件绑定语法来绑定
# 全局组件
需在 `main.js` 里进行`全局注册`，注册后就可在`所有页面里使用该组件`。
- Vue.component 的第一个参数必须是静态的字符串。
- nvue页面暂不支持全局组件
```js
//main.js
import Vue from 'vue'
import pageHead from './components/page-head.vue'
Vue.component('page-head',pageHead) //第一个参数必须是静态的字符串
```

# 常见问题解决
1. 如何获取上个页面传递的数据
在 onLoad 里得到，onLoad 的`参数`是其他页面打开当前页面所传递的数据。

2. 如何设置全局的数据和全局的方法
 uni-app 内置了 vuex 参考 模板 项目 ‘hello-uniapp’ 中的 ‘store/index.js’文件定义 
```js
//store.js
import Vue from 'vue'
import Vuex from 'vuex'
Vue.use(Vuex)
const store = new Vuex.Store({
    state: {...},
    mutations: {...},
    actions: {...}
})

export default store

//main.js
...
import store from './store'
Vue.prototype.$store = store
const app = new Vue({
    store,...
})
...

//test.vue 使用时：
import {mapState,mapMutations} from 'vuex'
``` 

3. 如何捕获 app 的 onError
由于 onError 并不是完整意义的生命周期，所以只提供一个捕获错误的方法，
在 app 的`根组件上`添加名为 onError 的回调函数即可。

4. 组件属性设置不生效解决办法
当重复设置某些属性为相同的值时，不会同步到view层
 例如：每次将scroll-view组件的scroll-top属性值设置为0，只有第一次能顺利返回顶部。 这和`props的单向数据流特性有关`，组件内部scroll-top的实际值改动后，其绑定的属性并不会一同变化。
 ```<scroll-view :scroll-top="scrollTop" scroll-y="true" @scroll="scroll">```
 - 解决办法1:
 监听scroll事件，记录组件内部变化的值，在设置新值之前先设置为记录的当前值
 ```css
export default {
    data() {
        return {
            scrollTop: 0,
            old: {
                scrollTop: 0
            }
        }
    },
    methods: {
        scroll: function(e) {
            this.old.scrollTop = e.detail.scrollTop
        },
        goTop: function(e) {
            this.scrollTop = this.old.scrollTop
            this.$nextTick(function() {
                this.scrollTop = 0
            });
        }
    }
}

```
- 解决办法1:
监听scroll事件，获取组件内部变化的值，实时更新其绑定值
```css
export default {
    data() {
        return {
            scrollTop: 0,
        }
    },
    methods: {
        scroll: function(e) {
            this.scrollTop = e.detail.scrollTop
        },
        goTop: function(e) {
            this.scrollTop = 0
        }
    }
}
```
第二种解决方式在某些组件可能造成抖动，推荐第一种解决方式。