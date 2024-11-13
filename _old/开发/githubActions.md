---
layout: post
title: githubActions
subtitle:
date:       2023-07-06 13:37:04
categories: [开发]
tags: [开发,githubActions]
---


 # 1. GitHub Action
持续集成由很多操作组成，比如抓取代码、运行测试、登录远程服务器，发布到第三方服务等等。
GitHub 把这些操作就称为 actions。

很多类似的操作完全可以共享，GitHub注意到了这一点，允许开发者把每个操作写成独立的脚本文件，
放置再代码仓库中，使得其他开发者可以引用。
不必自己写负责的脚本，直接引用写好的脚本，整个持续集成的过程变成一个Action组合。

# 2. Action仓库
[GitHub 官方市场](https://github.com/marketplace?type=actions)
[awesome仓库](https://github.com/sdras/awesome-actions)

# 3. Action
每个action 都是一个独立脚本，可以做成代码仓库，使用`userName/repoName`的语法引用Action
```
actions/setup-node   # 表示github.com/actions/setup-node 这个仓库 
					 # 代表一个action 
					 # 作用安装 Node.js
					 # 官方的 actions 都放在github.com/actions 中

```

## 3.1 action 版本
用户可以引用某个具体版本的action，版本用的是Git指针的概念
```
actions/setup-node@74bc508		#指向一个commit
actions/setup-node@v1.0			#指向一个标签
action/setup-node@master		#指向一个分支
```

## 3.2 Action基本概念
- workflow 工作流程
	持续集成一次运行的过程
- job 任务
	一个workflow由一个或多个jobs构成，即一次持续集成的运行可以完成多个任务
- step 步骤
	每个job 由多个step构成，一步步完成
- action 动作
	每个step可以一次执行一个或多个命令(action).
	

# 4. workflow 文件
Github Actinos 的配置文件 workflow，存放在代码仓库的`.github/workflow` 目录
格式为 yaml格式，文件名任意，
一个仓库可以有多个workflow文件，Github只要发现 `.github/workflow`目录里面有`.yml`，就会自动运行该文件

workflow配置字段非常多，详见[官方文档](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
下面是一些常见字段：
-  name
workflow 的名称，省略该字段，默认为当前workflow的文件名
- on
指定触发workflow的条件，通常是某些事件。
on 字段可以是事件的数组
```
on:push		#指定 push 事件触发 workflow
#或者
on:[push,pull_request]

```

指定触发事件可以限定分支或标签`on.<push|pull_request>.<tags|branches>`
```
on:
	push:
		branches:
			- master
```

- `jobs.<job_id>.name`
workflow 的文件主体是 jobs 字段，表示要执行的一项或多项任务。
jobs 需要写出每一项任务的 job_id,
job_id里面的name 字段是任务的说明：
```
jobs:
	my_first_job:
		name: My first job
	my_second_job:
		name: My second job
		
```

- jojbs.<job_id>.needs
needs 指定当前任务的依赖关系
```
jobs:
	job1:
	job2:
		needs: job1
	job3:
		needs:[job1,job2]
```

- jobs.<job_id>.runs-on
`run-on` 指定所需的虚拟机环境，必填
运行环境：
```
- ubuntu-latest, ubuntu-18.04 或者 ubuntu-16.04
- windows-latest, windows-2019
- macOS-latest 或者 macOS-10.14
```
```
runs-on: ubuntu-18.04
```

- jobs.<job_id>.steps

steps字段指定每个 Job 的运行步骤，可以包含一个或多个步骤。
每个步骤都可以指定以下三个字段。
```
jobs.<job_id>.steps.name：步骤名称。
jobs.<job_id>.steps.run：该步骤运行的命令或者 action。
jobs.<job_id>.steps.env：该步骤所需的环境变量。
下面是一个完整的 workflow 文件的范例。
```

##  完整的 workflow 文件的范例
```
name: Greeting from Mona
on: push

jobs:
  my-job:
    name: My Job
    runs-on: ubuntu-latest
    steps:
    - name: Print a greeting
      env:
        MY_VAR: Hi there! My name is
        FIRST_NAME: Mona
        MIDDLE_NAME: The
        LAST_NAME: Octocat
      run: |
        echo $MY_VAR $FIRST_NAME $MIDDLE_NAME $LAST_NAME.
```
# Action 的使用步骤
1. 仓库顶部的菜单会出现`Actions`一项,
2. 因此需要 GitHub 密钥。按照官方文档，生成一个密钥。然后，将这个密钥储存到当前仓库的Settings/Secrets里面。
并记住取的名字 脚本里的变量名 需要用到改名在
3. 生成一个标准的 React 应用
```
$ npx create-react-app github-actions-demo
$ cd github-actions-demo

```
打开package.json文件，加一个homepage字段，表示该应用发布后的根目录
```
"homepage": "https://[username].github.io/github-actions-demo",
```

4. 在这个仓库的.github/workflows目录，生成一个 workflow 文件，名字可以随便取 `xxx.yml` 文件
```
name: GitHub Actions Build and Deploy Demo
on:
  push:
    branches:
      - master
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@master

    - name: Build and Deploy
      uses: JamesIves/github-pages-deploy-action@master
      env:
        ACCESS_TOKEN: ${{ secrets.ACCESS_TOKEN }}
        BRANCH: gh-pages
        FOLDER: build
        BUILD_SCRIPT: npm install && npm run build
```
上面代码解释:
- 整个流程在master分支发生push事件时触发。
- 只有一个job，运行在虚拟机环境ubuntu-latest。
- 第一步是获取源码，使用的 action 是actions/checkout。
- 第二步是构建和部署，使用的 action 是JamesIves/github-pages-deploy-action。
			四个环境变量，分别为 GitHub 密钥、发布分支、构建成果所在目录、构建脚本。
		其中，只有 GitHub 密钥是秘密变量，需要写在双括号里面，其他三个都可以直接写在文件里。

# 搭建静态网页。
github提供模板，允许站内生成网页，但也允许用户自己编写网页，然后上传
Jekyll（发音/'dʒiːk əl/，"杰克尔"）是一个静态站点生成器，它会根据网页源码生成静态文件。它提供了模板、变量、插件等功能，所以实际上可以用来编写整个网站。

**先在本地编写符合Jekyll规范的网站源码，然后上传到github，由github生成并托管整个网站。**
## 建立步骤
1. 创建项目
	在你的电脑上，建立一个目录，作为项目的主目录,对该目录进行git初始化。
	```
	　$ mkdir jekyll_demo
	  $ cd jekyll_demo
	　$ git init
	```
2. 创建一个没有父节点的分支`gh-pages`。因为github规定，
只有该分支中的页面，才会生成网页文件
```
$ git checkout --orphan gh-pages # 创建一个没有父节点的分支gh-pages
```

3.以下所有动作，都在该分支下完成。
3.1 在项目根目录下，建立一个名为`_config.yml`的文本文件。
它是jekyll的配置文件，
我们在里面填入如下内容，其他设置都可以用默认选项，具体解释参见[官方网页](https://github.com/mojombo/jekyll/wiki/Configuration)。
```
　baseurl: /jekyll_demo
```

3.2 创建模板文件
根目录下，创建一个`_layouts目录`，用于存放模板文件，
进入该目录，创建一个`default.html文件`，作为**Blog的默认模板**。
并在该文件中填入以下内容
```
　<!DOCTYPE html>
　　<html>
　　<head>
　　　　<meta http-equiv="content-type" content="text/html; charset=utf-8" />
　　　　<title>{{ page.title }}</title>
　　</head>
　　<body>
　　　　{{ content }}
　　</body>
　　</html>
```

Jekyll使用[Liquid模板语言](https://github.com/shopify/liquid/wiki/liquid-for-designers)，`{{ page.title }}`表示文章标题，
`{{ content }}`表示文章内容，
更多模板变量请参考[官方文档](https://github.com/mojombo/jekyll/wiki/Template-Data)。

3.3. 创建文章
回到项目根目录，创建一个`_posts`目录，用于存放`blog文章`。
进入该目录，创建第一篇文章[文件名必须为`"年-月-日-文章标题.后缀名"`的格式,
如果网页代码采用html格式，后缀名为html；如果采用markdown格式，后缀名为md。]:
行首不能有空格

```
	---
　　layout: default
　　title: 你好，世界
　　---

　　<h2>{{ page.title }}</h2>

　　<p>我的第一篇文章</p>

　　<p>{{ page.date | date_to_string }}</p>

```

每篇文章的头部，必须有一个yaml文件头，用来设置一些元数据。它用三根短划线"---"，标记开始和结束
里面每一行设置一种元数据。"layout:default"，表示该文章的模板使用_layouts目录下的default.html文件；"title: 你好，世界"，表示该文章的标题是"你好，世界"，如果不设置这个值，默认使用嵌入文件名的标题
在yaml文件头后面，就是文章的正式内容，里面可以使用模板变量

3.4. 创建首页
有了文章以后，还需要有一个首页。
回到根目录，创建一个index.html文件，填入以下内容
```
	---
　　layout: default
　　title: 我的Blog
　　---
　　<h2>{{ page.title }}</h2>
　　<p>最新文章</p>
　　<ul>
　　　　{% for post in site.posts %}
　　　　　　<li>{{ post.date | date_to_string }} <a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></li>
　　　　{% endfor %}
　　</ul>
```

Liquid模板语言规定，输出内容使用两层大括号，单纯的命令使用一层大括号。至于{{site.baseurl}}就是_config.yml中设置的baseurl变量。

目录结构变成:
```
/jekyll_demo
　　　　|--　_config.yml
　　　　|--　_layouts
　　　　|　　　|--　default.html
　　　　|--　_posts
　　　　|　　　|--　2012-08-25-hello-world.html
　　　　|--　index.html
```

4. 发布内容
先把所有内容加入本地git库
```
$ git add .
$ git commit -m "first post"
```
前往github的网站，在网站上创建一个名为jekyll_demo的库，再将本地内容推送到github上你刚创建的库
```
$ git remote add origin https://github.com/username/jekyll_demo.git
$ git push origin gh-pages
```

5. 访问
上传成功之后，等10分钟左右，
访问http://username.github.com/jekyll_demo/就可以看到Blog已经生成了

6. 绑定域名
果你不想用http://username.github.com/jekyll_demo/这个域名，可以换成自己的域名
具体方法是在repo的根目录下面，新建一个名为CNAME的文本文件，里面写入你要绑定的域名，比如example.com或者xxx.example.com。

如果绑定的是顶级域名，则DNS要新建一条`A记录`，指向`204.232.175.78`.
如果绑定的是二级域名，则DNS要新建一条`CNAME记录`，指向username.github.com
此外，别忘了将_config.yml文件中的baseurl改成根目录"/"。
