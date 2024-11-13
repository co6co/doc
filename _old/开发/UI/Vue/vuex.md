---
layout: post
title: vuex
subtitle:
date:       2021-04-15 13:22:45
categories: [Vue]
tags: [Vue,vuex]
---


# vuex  状态管理
vuex是状态管理，是为了解决**跨组件之间数据共享**问题的，
一个组件的数据变化会映射到使用这个数据的其他组件当中。
如果刷新页面，之前存储的**vuex数据全部都会被初始化掉**。
以一个全局单例模式管理当应用遇到多个组件共享状态时使用Vuex，即：多个视图依赖于同一个状态，不同视图的行为需要变更同一状态。

1、Vuex 的状态存储是响应式的。当 Vue 组件从 store 中读取状态的时候，若 store 中的状态发生变化，那么相应的组件也会相应地得到高效更新。
2、你**不能直接改变 store 中的状态**。改变 store 中的状态的唯一途径就是**显式地提交 (commit) mutation**。这样使得我们可以方便地跟踪每一个状态的变化，
从而让我们能够实现一些工具帮助我们更好地了解我们的应用。
 

vuex分为`state`，`getter`，`mutation`，`action`四个模块,
vuex中的`mapState`，`mapGetters`，`mapActions`，`mapMutations`均是辅助函数。
````js
import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex);

export default new Vuex.Store({
  //存放状态，类似于data
  state: {
    nickname:'qiqi',
    age:18,
    gender:'女',
    firstname:'李',
    lastname:'辉',
    days:1000,
  },
  //store.“getter“ 类似于 计算属性 依赖值发生了改变才会被重新计算
  getters:{
	realname(state){
      return state.firstname+state.lastname
    },
    days_us(state){
      return (state.days/7).toFixed(2)
    }
  },
  ////类似于methods
  mutations: {
	addAge(state){  //可以传入 其他参数 [age]， this.$store.commit('addAge',100);
      state.age++;
    }
  },
  // 提交的是 mutation
  actions: {
	addAgeAction({ commit }){
      commit('addAge');
    }
  },
  modules: {}
})
````

不使用mapState时，store 实例会注入到根组件下的所有子组件中，且子组件能通过 `this.$store` 访问到.

当一个组件需要获取多个状态的时候，将这些状态都声明为计算属性会有些重复和冗余。
为了解决这个问题，我们可以使用 `mapState` 辅助函数帮助我们`生成计算属性`
不做为组件输入模块 ，直接在组件中 导入使用
## 1. state
	定义变量
	我们需要在state中定义变量，类似于vue中的data，通过state来存放状态。
	```
	import {mapState} from 'vuex'
	computed:{
            ...mapState(['nickname','age','gender'])
			//等价于下面的 代码
			// nickname(){
            //     return this.$store.state.nickname;
            // },
            // age(){
            //     return this.$store.state.age;
            // },
            // gender(){
            //     return this.$store.state.gender;
            // }
	}
	```
## 2. getter
	获取变量，可以不使用  `mapGetter` 来获取值   `this.$store.getters.realname;`
	```
	import {mapGetters} from 'vuex'
	export default {
		computed:{
            // realname(){
            //     return this.$store.getters.realname;
            // },
            // days_us(){
            //     return this.$store.getters.days_us;
            // },
            ...mapGetters(['realname','days_us']),
        }
	}
	
	```
	
## 3. mutation   必须是**同步函数**
	同步执行对变量进行的操作,更改 vuex 的 store 中的状态的唯一方法是提交 mutation。
	vuex 中的 `mutation` 非常类似于`事件`：每个 mutation 都有一个字符串的事件类型 (type) 和 一个 回调函数 (handler)。
	这个回调函数就是我们实际进行状态更改的地方，并且它会接受 state 作为第一个参数。
	
	使用 this.$store.commit('xxx') 提交 mutation
	```
	 import {mapMutations} from 'vuex'
    export default {
        name: "Vhome",
        methods:{
            // test(){							//<div><button @click="test">使用mutations年龄加1</button></div>
            //     this.$store.commit('addAge')
            // },
            ...mapMutations(['addAge'])			//<div><button @click="addAge">使用mutations年龄加1</button></div>
        }
    }
	```
## 4. action
	异步执行对变量进行的操作,
	Action 类似于 mutation，不同在于：]
	- Action 提交的是 `mutation`，而`不是直接变更状态`。
	- Action 可以包含任意异步操作。
	```
	import {mapActions} from 'vuex'
	export default {
	  methods:{
            test1(){								//<div><button @click="test1">使用actions使年龄加1</button></div>
               this.$store.dispatch('addAgeAction')
            },
			 ...mapActions(['addAgeAction']) 		//<div><button @click="addAgeAction">使用actions使年龄加1</button></div>
      }
	}
	```
	
## 5. 测试代码
```
//store.js 
import Vue from 'vue';
import Vuex from 'vuex'

Vue.use(Vuex)

const store=new Vuex.Store({
	state:{
		appName:"学习项目",
		appId:"hQEMA4fLSGZcsDhlAQf/SXQJKKKyZ5SJPn2vH3qgmqBQ8QD9EI2FcAJP9MZuKyl6",
		age:11 ,
		firstName:'陈',
		lastName:'先'
	},
	getters:{
		fullName(state){
			return state.firstName+state.lastName;
		}
	 
	},
	mutations:{
		newYear(state){
			state.age++;
		}
	},
	actions:{
		addYear({commit}){
			setTimeout(function(){
					commit('newYear');
			},2000); 
		}
	},
	modules:{}
}) 
export default store;
```
```
//main.js

import Vue from 'vue'
import App from './App' 
import store from './store'

Vue.config.productionTip = false 
App.mpType = 'app'

const app = new Vue({
	store,
    ...App
})
app.$mount()

```

```
//page.vue
<template>
	<view>
		<view><text class="name">应用ID:</text>{{appId}}</view>
		<view><text class="name">应用名称：</text>{{appName2}} -{{appName}}</view>
		<view><text class="name">第一个名字：</text>{{firstName}} <text class="name">第二个名字:</text>{{lastName}}<text class="name">  全名：</text>{{fullName}} </view> 
		<view><text class="state">将状态 state.age 放在 data 中：</text>有 {{jisui}}岁了<text class="state">只有当页面隐藏后再显示才会重新读取</text></view>
		 
		<view> <text class="name">年龄：</text>{{age}}</view>
		<view style="display: flex; align-items: flex-start; flex-direction: row;">
			<button @click="passYear">过了一年</button>
			<button @click="newYear">又过了一年</button>
			<button @click="slowPassword">慢慢的过了一年</button>
			<button @click="addYear">慢慢的又过了一年</button>
		</view>
	</view>
</template>

<script>
	import {mapState,mapGetters,mapMutations,mapActions} from 'vuex';
	export default {
		data() {
			return {
				jisui:this.$store.state.age
			}
		},
		computed:{
			appName2(){
				return this.$store.state.appName;
			},
			...mapState(['appName','appId','age','firstName','lastName']),
			...mapGetters(['fullName']),
			
		},
		methods: {
			passYear(){
				this.$store.commit("newYear");
			},
			...mapMutations(["newYear"]),
			slowPassword(){
				this.$store.dispatch("addYear")
			},
			...mapActions(["addYear"]) 
		}
		
	}
</script>

<style>
.state{color: #C0C0C0;}
.name{width: 200rpx; display: inline-block;text-align: right; color: #E8C7CC;}
button{width: 400rpx; margin: 10rpx;}
</style>

```
## 运行后图片
![vuex 测试](./static/开发/UI/Vue/imgs/vue/vuex.png)
