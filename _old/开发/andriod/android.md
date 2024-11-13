---
layout: post
title: android
subtitle:
date:       2023-03-22 17:12:17
categories: [andriod]
tags: [andriod,android]
---


# 1. 优化 Snackbar
取代用户和应用程序之间消息传递[Toast]；,解决一些问题，热暖是全新的外观模式：
```
Snackbar.make(parentView,message_txt,duration)
	.setAction(action_txt,click_listener)
	.show()
```

开源项目Anko 的辅助函数：
```
snackba(parentView,action_txt，message_txt){click_listener}
```

# 2. 用户扩展封装Utils
```
fun Context.isMobileConnected():Boolean{
	val networkInfo=connectivyManager.activeNetworkInfo
	if(networkInfo!=null)return networkInfo.isAvailable
	return false
}
```

Context的生命周期需要进行很好的把控，我们应该使用ApplicationContext，防止周期不一致导致的内存泄露等问题；
