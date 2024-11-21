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

<h2>类别 {{site.categories.ad}}</h2>
<ul>
    {% for category in site.categories %}
      <li>
        <strong>{{ category[0] }}</strong> 
        <ul>
          {% for post in category[1] %}
          <li>
              <a href="{{ post.url }}">{{ post.title }}</a> 
          </li> 
          {% endfor %}
        </ul>
      </li>
    {% endfor %}

</ul>
