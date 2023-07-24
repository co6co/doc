---
layout: default
title: python.py 转exe
---

# 1. 安装模块
```
pip install pyinstaller
```

# 2. 打包
```
pyinstaller [options] script [script …] | specfile [options]
	#script是要转换的Python脚本，可以是单个文件或多个文件。
	#specfile是一个可选的配置文件，可以用来定制转换过程。
	#options是一些可选的选项
	

pyinstaller test.py	#test.py所在目录下生成一个dist目录，其中包含生成的exe文件
pyinstaller -d /path/to/output test.py # 指定输出
pyinstaller -n myapp test.py 指定生成的exe文件名

pyinstaller --onefile test.py #默认情况下，pyinstaller生成的exe文件是一个可执行文件和一些相关文件的集合，需要将它们一起放在同一目录下才能运行。
								#如果需要生成一个单独的exe文件，可以使用--onefile选项
```