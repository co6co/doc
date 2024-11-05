---
layout: post
title:  typescript 问题总结
subtitle: 
description: 

header-img: 
date:       2024-06-12 14:51:01
categories: [TypeScript,npm ]
tags: [基础, ]
---

# 1. typings 文件夹
特殊文件夹，用于存放第三方库或模块的类型定义文件，为那些没有使用 TypeScript 编写的 JavaScript 库提供类型定义
ypeScript 2.0 常手动编写，使用定义文件（.d.ts）来为第三方库添加类型定义，而在 TypeScript 2.0 及以后的版本中，不再需要手动编写定义文件，而是通过 npm 安装所需库的 @types 包来获取类型定义

# 2. vscode
保存`Files: Insert Final Newline` 最后一行回车

# 2. vite alias
```
//vite.config
import { resolve } from 'path'; // 主要用于alias文件路径别名  pnpm install -D path
export default defineConfig({
	resolve: {
		alias: {
			'@': resolve(__dirname, 'src')//npm install --save-dev @types/node
		}, 
	},
})

//tsconfig.json
{
	"compilerOptions": {
		...
		"baseUrl": "./",
			"paths": {
				"@/*": ["src/*"]
			}
		...
	}
	...
}
```
