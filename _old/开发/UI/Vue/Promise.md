---
layout: post
title: Promise
subtitle:
date:       2021-04-15 16:20:10
categories: [Vue]
tags: [Vue,Promise]
---


# promise
```
new Promise(
  function (resolve, reject) {
    // 一段耗时的异步操作
    resolve('成功') // 数据处理完成
    // reject('失败') // 数据处理出错
  }
).then(
  (res) => {console.log(res)},  // 成功
  (err) => {console.log(err)} 	// 失败
)
```
## resolve作用
将Promise对象的状态从“未完成”变为“成功”（即从 pending 变为 resolved），在异步操作成功时调用，并将异步操作的结果，作为参数传递出去；
##  reject作用
将Promise对象的状态从“未完成”变为“失败”（即从 pending 变为 rejected），在异步操作失败时调用，并将异步操作报出的错误，作为参数传递出去。

## promise有三个状态：
1. 、pending[待定]初始状态
2. 、fulfilled[实现]操作成功
3. 、rejected[被否决]操作失败

>当promise状态发生改变，就会触发then()里的响应函数处理后续步骤；
>promise状态一经改变，不会再变。
>Promise对象的状态改变，只有两种可能：

>从pending变为fulfilled,从pending变为rejected。
> 这两种情况只要发生，状态就凝固了，不会再变了。

## .then()
1. 、接收两个函数作为参数，分别代表fulfilled（成功）和rejected（失败）
2. 、.then()返回一个新的Promise实例，所以它可以链式调用
3. 、当前面的Promise状态改变时，.then()根据其最终状态，选择特定的状态响应函数执行
4. 、状态响应函数可以返回新的promise，或其他值，不返回值也可以我们可以认为它返回了一个null；
5. 、如果返回新的promise，那么下一级.then()会在新的promise状态改变之后执行
6. 、如果返回其他任何值，则会立即执行下一级.then()

### .then()里面有.then()的情况
1. 、因为.then()返回的还是Promise实例
2. 、会等里面的then()执行完，再执行外面的 
