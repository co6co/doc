---
layout: post
title: "我的第一篇博客"
date: 2023-10-01
categories: [技术, 教程]
tags: [Jekyll, 博客]
---

这是我的第一篇博客文章。
![点集计算]({{ "/static/imgs/ai/dot.png" | prepend: site.baseurl }})
<ul>
{% for item in site.categories %}
    <li>
    <small>{{item[0]}}</small> 
    </li>
{% endfor %}
</ul>
