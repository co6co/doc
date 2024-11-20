---
layout: page
title: 测试页面了
subtitle:
description:
header-img:
date: 2023-7-20 00:00:01
categories:
  - 临时1
  - 临时2
tags:
  - 测试1
---

# 中文页面

<h2>类别</h2>
<ul>
    {% for category in site.categories %}
      <li>
        <strong>{{ category[0] }}</strong> 
      </li>
    {% endfor %}
</ul>
