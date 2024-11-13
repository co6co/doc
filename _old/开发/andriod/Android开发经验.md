---
layout: post
title: Android开发经验
subtitle:
date:       2023-04-23 11:34:48
categories: [andriod]
tags: [andriod,Android开发经验]
---


# 模型
## 1.1 MVC
- mvc中 Model类没有对Android类的任何引用，应可以直接进行单元测试；
- Controller 不会扩展或实现任何Android类，并且应该引用View的接口类；
	通过这种方式，也可以对控制器进行单元测试
	
	如果View遵循单一职责原则，那么他们的角色就是为每个用户事件更新Controller，
	只显示Model中的数据，而不是嫌任何业务逻辑
	在这种理想的作用下，UI测试应该足以覆盖所有的View的功能；

Mvc模式中View对MOdel是由着强依赖的，当View非常复杂时，为了最小化View 中的逻辑，Model应该能能够为要显示的每个视图提供可测试的方法
这将增加大量的类和方法[代码相当冗余]
由于View依赖于Controller和Model，Ui逻辑中的一个更改可能导致需要修改很多类，这降低了灵活性，且导致UI难以测试；
Android的视图组件中，有着非常明显的生命周期，对于MVC模式我们有时不得不将处理视图逻辑的代码都写在这些组件中造成他们十分臃肿；

## 1.2 MVP
对应的时MODEL[数据层]、VIEW[视图层] 、 Presenter[逻辑层]
- M 负责管理业务逻辑和处理网络或数据库API
	使用远程或本地数据源 来获取或保存数据,以获取代办事项为例，我面请求列表数据时，model有限尝试从本地获取数据，如果为空，则查询网络更新本地数据并返回；
- V 显示并将用户操作的信息通知给Presenter，Activity、Fragment和自定义视图都是View
	View 通过Presenter来发起获取数据的指令，在TODO项目中所有View都实现了允许设置Presenter的BaseView接口
- P 从Model中检索数据，应用UI逻辑并管理VIew状态，决定显示什么，以及对View的事件做出相应；

相对于MVC 其设计思路的核心时提出了Presenter层，它时View层于Model层沟通的桥梁，对业务逻辑进行处理，这符合我们理想中的单一之策原则；

`github.com/googlesamples/android-architecture` 它允许用户创建、读取、更新、和删除 待办事项 任务；以及对任务列表进行分类显示；

### 1.2.1 mvp易产生的问题
- 接口粒度难以掌握
	MVP将模块职责良好的分离，但开发小规模APP或原型时，这增加了开销[对于每个业务场景我们都要写 `Activity-View-Presenter-Contract `]，
- Presenter逻辑容易过重
- Presenter和View相互引用
	在Presenter和view中都会保持一份对方的引用，

## 1.3 MVVM (model-view-binder)
- Model 与ViewModel配合，可以获取和保存数据
- View 用户的动作通知给ViewModel
- ViewModel 暴露公共属性与View相关的 数据流，通常为Model和View绑定关系

![MVVM](/static/开发/andriod/imgs/MVVM.png)

如果MVP模式意味着Presenter直接告诉View要显示的内容，那么在MVVM中，ViewModel回公开Views可以绑定的事件流，
这样ViewModel不再需要保持对View的引用，但发挥了Presenter一样的作用；这意味着MVP模式所需的所有接口现在都被删除了；

MVVM易造成的问题：
- 需要更多精力定位BUG，由于双向绑定，视图中的异常排查起来比较麻烦；
- 通用的View需要更好的设计 当一个View要变成通用组件时，该View对应的Model通常不能复用，在整体架构设计不完善时，我们很容易创建一些冗余的Model

## 1.4 单向数据流模型 Flux
Flux组成：
- View 显示UI
- Action	用户操作界面时，视图层发出的消息
- Dispatcher 分发器，用于接收Actions，执行回调函数
- Store 数据层，类似于MV* 的Model层，用于存放应用的状态，一旦发生变动，提醒View更新页面

![Flux单向数据流模型](/static/开发/andriod/imgs/Flux.png)

用户通过与View交互或者外部产生一个Action，Dispatcher接收到Action并执行那些已经注册的回调，向所有Store分发Action。
通过注册的回调，Store相应那些与他们所保存的状态有个的Action。然后Store回触发一个Change事件，来提醒对应的View数据以及发生了改变，View监听这些事件并重新从Stroe中获取数据。
这些View调用它们自己的`setState()`方法，重新渲染自身及相关联的组件；

除了Flux外，当前Web前端比较常用的React也是比较典型的单向数据流框架，它也是基于**Redux模型**实现的。

### 1.4.1 Redux
Redux作为Flux模型一个友好简洁的实现，它基于一个严格的单向数据流；
应用中的所有数据都是通过组件在一个方向上流动。Redux希望确保应用的视图时根据确定的状态来呈现的[即在任何阶段，应用的状态总是确定、有效的，并且可以转换到另一个可预测、有效的状态]
视图将根据所处的状态来进行对应的展示。

Redux的核心位3个部分：
- Store 保存应用的状态并提供发放来存储对应的状态，分发状态并注册监听；
- Actions 与Flux类似，包含要传递给Store的信息，辨明我们希望怎样改变应用的状态
	比如
	```
	data class AddTodoAction(val title:String,val content:String)
	```
	然后再由Store进行分发:
	```
	store.dispatch(AddTodoAction("Finsh you homeWork","English And Math"))
	```
- Reducers Store 收到Action以后，必须给出一个新的State，这样View才会发生变化，这种State的计算过程叫做Reducer：
  ```
  fun reduce (oldState:AppState,action:Action)：AppState{
	return when(action){
		is AddTodoAction ->{
			oldState.copy(todo=...)
		}
		else ->oldState
	}
  }
  
  ```
![Redux 数据流](/static/开发/andriod/imgs/Redux.png)

表 Flux与Redux比较

||Flux|Redux|
|--:|--|--|
|数据源|一个应用由多个数据源(通常是一个业务场景一个Store)|通常仅有一个Store|
|分发机制|利用一个单例对象Dispatcher进行所有事件分发|没有调度对象实体，Store中以及完成了Dispatch，我们使用其暴露的接口完成事件分发|
|Store|可读写，对数据的操作逻辑一般放在Store中|只可读，逻辑放在Reducer中，它接收先前的状态和一个动作，并根据该动作返回新的状态，Reducer通常是一个纯函数，如果无法确保其位纯函数，可以使用Middleware|

### 1.4.2 单数据流优势
最大优势在于整个应用中数据流以单向流动的方式，从而使得拥有更好的可预测性与可控性，这样可保证应用各个模块间的松耦合性。

- 优秀的数据追朔能力
- 更简洁的单元测试

Redux是基于Flux的思想产生的，所以再Redux架构中构造组件，通常回产生很多样板代码，而使用Kotlin可更加方便地管理样板代码：
```
fun reduce(Action action,oldState：AppState):AppState{
	return when(action){
		is AddTodoAction -> reduceAddTodoAction(OldState,action)
		is RemoveTodoAction -> reduceAddTodoAction(OldState,action)
		else ->oldState
	}
}
```
这只是Kotlin提升Redux架构便捷性的冰山一角，虽然Redux起源于Web端，但从他的构建中，我们可以看到很多非常好的想法，即使我们的平台语言和工具可能不同，但是再架构层面，我们面对着许多相同的级别问题，比如，尽可能降低View和业务代码的耦合度等。

## 1.5 Rekotlin
在IOS中，有一个著名的单向数据流框架：ReSwift，随着Kotlin在Android中的地位不断提高利用其优秀的语言特性也派生出了类似的框架：ReKotlin，它的出现宣布Android即将跨入单向数据流时代。

基于经典的Redux模型，ReKotlin也奉行以下设计：
- The Store: 以单一数据结构管理整个App的状态，状态只能通过dispatching Actions来进行修改，每当Store中的状态改变了，它就会通知所有的Observers。
- Actions 通过陈述的形式来描述一次状态变更，操作中不包含任何代码，通过Store转发给Reducers。Reducers会接收这些Actions，然后进行相应的状态逻辑变更。
- Reducers 基于当前的Action和App状态，通过纯函数来返回一个新的App状态。

核心思想于Redux基本一致： 单向数据流意味着应用程序的State不应该保存在很多不同的地方，相反，存储组件将所有State保存在中心位置。
View会对此State的更改做出反应，而不是在内部处理它。Action是触发State更改的唯一方法，它不会通过它们自己来更改状态，而更像是一些指令。表示某些内容将发生变化。
这些“指令”是针对使用执行实际状态更改的Reducers的Store对象发出的。另外还有Middleware，它主要用来处理副作用。

[示例代码](https://github.com/DiveIntoKotlin/DiveIntoKotlinSamples)
