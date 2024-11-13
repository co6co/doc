---
layout: post
title: mongoDb
subtitle:
date:       2021-12-10 17:00:12
categories: [数据库]
tags: [数据库,mongoDb]
---


```
db.createUser({user:"root",pwd:"root",roles:[{role:"root",db:"admin"}]})
db.auth("user","user");
```