---
layout: post
title: typing模块和类型注解
subtitle: 
description: 在 Python 3.5 中，Python PEP 484 引入了类型注解（type hints），在 Python 3.6 中，PEP 526 又进一步引入了变量注解（Variable Annotations）
header-img: {{site.img}}/post-bg-ios9-web.jpg
date:       2023-7-18 12:03:16
---

# 1. 变量注解
示例：
```
#不知道列表、元组、字典中存的是什么类型，
names: list = ['Germey', 'Guido']
version: tuple = (3, 7, 4)
operations: dict = {'show': False, 'sort': True}
```
引入typing
typing 模块也已经被加入到 Python 标准库中，typing 中的注解元素包括:List、Tuple、NamedTuple、Dict、Mapping、MutableMapping、Set、AbstractSet、Sequence、NoReturn、Any
```
from typing import List, Tuple, Dict
names: List[str] = ['Germey', 'Guido']
version: Tuple[int, int, int] = (3, 7, 4)
operations: Dict[str, bool] = {'show': False, 'sort': True}
``` 
## 1.1 Tuple、NamedTuple
元组:
```
person: Tuple[str, int, float] = ('Mike', 22, 1.75) #名字，年龄，身高

```
`NamedTuple`，是 collections.namedtuple 的泛型，实际上就和 namedtuple 用法完全一致。
## 1.2. List
List列表，是 list 的泛型，基本等同于 list，其后紧跟一个方括号，里面代表了构成这个列表的元素类型:
```
list_1:List[int or float] = [2, 3.5]
list_2: List[List[int]] = [[1, 2], [2, 3]]
```
## 1.3 Dict、Mapping、MutableMapping
Dict、字典，是 dict 的泛型；Mapping，映射，是 collections.abc.Mapping 的泛型。
**Dict 推荐用于注解返回类型，Mapping 推荐用于注解参数**,后跟一个中括号，中括号内分别声明键名、键值的类型
```
def size(rect: Mapping[str, int]) -> Dict[str, int]:
	return {'width': rect['width'] + 100, 'height': rect['width'] + 100}

```
MutableMapping 则是 Mapping 对象的子类，在很多库中也经常用 MutableMapping 来代替 Mapping。

## 1.4. Set、AbstractSet
Set是 set 的泛型；AbstractSet、是 collections.abc.Set 的泛型.Set 。
**推荐用于注解返回类型，AbstractSet 用于注解参数.**
```
def describe(s: AbstractSet[int]) -> Set[int]:
	return set(s)
```

## 1.5. Sequence
是 collections.abc.Sequence 的泛型,在某些情况下，我们可能并不需要严格区分一个变量或参数到底是list 类型还是 tuple 类型，我们可以使用一个更为泛化的类型，叫做 Sequence，其用法类似于 List：
```
def square(elements: Sequence[float]) -> List[float]:
	return [x ** 2 for x in elements]   
```
## 1.6. NoReturn
当一个方法没有返回结果时，为了注解它的返回类型，我们可以将其注解为 NoReturn
```
def hello() -> NoReturn:
	print('hello')
```

## 1.7. Any
是一种特殊的类型，它可以代表所有类型，静态类型检查器的所有类型都与 Any 类型兼容，所有的无参数类型注解和返回类型注解的都会默认使用 Any 类型，也就是说，下面两个方法的声明是完全等价的：
```
	def add(a):
		return a + 1

	def add(a: Any) -> Any:
		return a + 1
```


# 2. 类型注解

## 2.1. TypeVar
可以借助它来自定义兼容特定类型的变量，比如有的变量声明为 int、float、None 都是符合要求的，可用 TypeVar 来表示：
```
# 定义某物体的高度
height = 1.75
Height = TypeVar('Height', int, float, None)
def get_height() -> Height:
	return height
```

## 2.2. NewType
声明一些具有特殊含义的类型，例如像 Tuple 的例子一样，我们需要将它表示为 Person,但从表面上声明为 Tuple 并不直观，所以我们可以使用 NewType 为其声明一个类型:
```
Person = NewType('Person', Tuple[str, int, float])
person = Person(('Mike', 22, 1.75)) #实际上 person 就是一个 tuple 类型
```

## 2.3. Callable
可调用类型，它通常用来注解一个方法。
```
print(Callable, type(add), isinstance(add, Callable))
>>>typing.Callable <class 'function'> True
```
Callable 在声明的时候需要使用 Callable[[Arg1Type, Arg2Type, ...], ReturnType] 这样的类型注解，将参数类型和返回值类型都要注解出来：
```
def date(year: int, month: int, day: int) -> str:
	return f'{year}-{month}-{day}'

def get_date_fn() -> Callable[[int, int, int], str]:
	return date
```
说明:首先声明了一个方法 date，接收三个 int 参数，返回一个 str 结果，get_date_fn 方法返回了这个方法本身，它的返回值类型就可以标记为 Callable，中括号内分别标记了返回的方法的参数类型和返回值类型。

## 2.4. Union
联合类型，Union[X, Y] 代表要么是 X 类型，要么是 Y 类型。 联合类型的联合类型等价于展平后的类型：
```
Union[Union[int, str], float] == Union[int, str, float]
Union[int] == int                                           #一个参数的联合类型会坍缩成参数自身
Union[int, str, int] == Union[int, str]                     #多余的参数会被跳过
Union[int, str] == Union[str, int]                          #参数顺序会被忽略



def process(fn: Union[str, Callable]):
	isinstance(fn, str):
		# str2fn and process
		pass
	isinstance(, Callable):
		fn()
```

## 2.5. Optional
参数可以为空或已经声明的类型，即 Optional[X] 等价于 Union[X, None]，这个并不等价于可选参数，当它作为参数类型注解的时候，不代表这个参数可以不传递了，而是说这个参数可以传为 None。 如当一个方法执行结果，如果执行完毕就不返回错误信息， 如果发生问题就返回错误信息，则可以这么声明：
```
def judge(result: bool) -> Optional[str]:
	if result: return 'Error Occurred'
```

2.6. Generator
代表一个生成器类型,声明比较特殊，其后的中括号紧跟着三个参数，分别代表 YieldType、SendType、ReturnType
```
def echo_round() -> Generator[int, float, str]:
	sent = yield 0
	while sent >= 0:
		sent = yield round(sent)
	return 'Done'
```
yield 关键字后面紧跟的变量的类型就是 YieldType，yield 返回的结果的类型就是 SendType，最后生成器 return 的内容就是 ReturnType。 当然很多情况下，生成器往往只需要 yield 内容就够了，我们是不需要 SendType 和 ReturnType 的，可以将其设置为空：
```
def infinite_stream(start: int) -> Generator[int, None, None]:
	while True:
		yield start
		start += 1
```