# 1. Jekyll 参考官网
|文件 / 目录|描述|
|--             |-- |
|_config.yml    | 存储的是 配置 信息。其中许多 参数是可以在命令行中指定的，但是 在此文件中进行设置会更容易些，并且你不必记住它们。|
|_drafts        | 草稿（Drafts）是未发布的文章（posts）。这些文章的文件名中没有包含 日期： title.MARKUP |
|_includes      |   方便重用 `{% include file.ext %}` 或者 `_includes/file.ext`|
|_layouts       |`{{ content }}`|
|_posts         |`YEAR-MONTH-DAY-title.MARKUP`|
|_data          |格式化的站点数据应当放在此目录下。Jekyll 将自动加载此目录下的所有数据文件（支持 .yml、 .yaml、.json、.csv 或 .tsv 格式和扩展名）， 然后就可以通过 `site.data` 来访问了。假定在 此目录下有一个文件名为 members.yml 的文件，那么你可以通过 site.data.members 变量来访问该文件中的内容。|
|`_sass`        | 这些事可以导入（import）到 main.scss 文件中的 sass 代码片段， main.scss 文件最终经过处理之后形成一个独立的样式文件 main.css 并被用于整个站点。|
|_site          | 在 Jekyll 转换完所有的文件之后，将在此目录下放置生成的站点（默认情况下）。 最好将此目录添加到 .gitignore 文件中。|
|.jekyll-metadata | This helps Jekyll keep track of which files have not been modified since the site was last built, and which files will need to be regenerated on the next build. This file will not be included in the generated site. It’s probably a good idea to add this to your .gitignore file.|
|index.html or index.md and other HTML, Markdown files|Provided that the file has a front matter section, it will be transformed by Jekyll. The same will happen for any .html, .markdown, .md, or .textile file in your site’s root directory or directories not listed above.|
|index.html or index.md  or otherName.index[md]|rovided that the file has a front matter section, it will be transformed by Jekyll. The same will happen for any .html, .markdown, .md, or .textile file in your site’s root directory or directories not listed above.|
|其它文件/目录|除了上面列出的目录和文件外，其它所有目录和文件（例如 css 和 images 目录， favicon.ico 等文件）都将一一复制到 生成的站点中。已经有大量 站点 在使用 Jekyll 了，你可以参考这些站点以了解如何运用这些文件和目录。|
# 2.变量
## 2.1 全局变量
|VARIABLE |	DESCRIPTION|
|--             |-- |
|site|Site wide information + configuration settings from _config.yml. See below for details.|
|page|Page specific information + the front matter. Custom variables set via the front matter will be available here. See below for details.|
|layout|Layout specific information + the front matter. Custom variables set via front matter in layouts will be available here.|
|content|In layout files, the rendered content of the Post or Page being wrapped. Not defined in Post or Page files.|
|paginator|When the paginate configuration option is set, this variable becomes available for use. See Pagination for details.|

## 2.2 站点（Site）变量
|VARIABLE |	DESCRIPTION|
|--             |-- |
|site.time|The current time (when you run the jekyll command).|
|site.pages|A list of all Pages.|
|site.posts|A reverse chronological list of all Posts.|
|site.related_posts|If the page being processed is a Post, this contains a list of up to ten related Posts. By default, these are the ten most recent posts. For high quality but slow to compute results, run the jekyll command with the --lsi (latent semantic indexing) option. Also note GitHub Pages does not support the lsi option when generating sites.|
|site.static_files|A list of all static files (i.e. files not processed by Jekyll's converters or the Liquid renderer). Each file has five properties: path, modified_time, name, basename and extname.|
|   site.html_pages|   A subset of site.pages listing those which end in .html.|
|   site.html_files|   A subset of site.static_files listing those which end in .html.|
|   site.collections|   A list of all the collections (including posts).|
|   site.data|   A list containing the data loaded from the YAML files located in the _data directory.|
|   site.documents|   A list of all the documents in every collection.|
|   site.categories.CATEGORY|   The list of all Posts in category CATEGORY.|
|   site.tags.TAG|   The list of all Posts with tag TAG.|
|   site.url|   Contains the url of your site as it is configured in the _config.yml. For example, if you have url: http://mysite.com in your configuration file, then it will be accessible in Liquid as site.url. For the development environment there is an exception, if you are running jekyll serve in a development environment site.url will be set to the value of host, port, and SSL-related options. This defaults to url: http://localhost:4000.|
|site.[CONFIGURATION_DATA]|All the variables set via the command line and your _config.yml are available through the site variable. For example, if you have foo: bar in your configuration file, then it will be accessible in Liquid as site.foo. Jekyll does not parse changes to _config.yml in watch mode, you must restart Jekyll to see changes to variables.|

## 2.3  页面（Page）变量
|   VARIABLE	|DESCRIPTION|  
|--             |-- |  
|   page.content|    The content of the Page, rendered or un-rendered depending upon what Liquid is being processed and what page is.|   
|   page.title|    The title of the Page.| 
|   page.excerpt|     The un-rendered excerpt of a document.| 
|   page.url|     The URL of the Post without the domain, but with a leading slash, e.g. /2008/12/14/my-post.html|    
|   page.date|    The Date assigned to the Post. This can be overridden in a Post’s front matter by specifying a new date/time in the format YYYY-MM-DD HH:MM:SS   (assuming UTC), or YYYY-MM-DD HH:MM:SS +/-TTTT (to specify a time zone using an offset from UTC. e.g. 2008-12-14 10:30:00 +0900). | 
|   page.id|   An identifier unique to a document in a Collection or a Post (useful in RSS feeds). e.g. /2008/12/14/my-post/my-collection/my-document|
|   page.categories|   The list of categories to which this post belongs. Categories are derived from the directory structure above the _posts directory. For example, a post at /work/code/_posts/2008-12-24-closures.md would have this field set to ['work', 'code']. These can also be specified in the front matter.|
|   page.collection|   The label of the collection to which this document belongs. e.g. posts for a post, or puppies for a document at path _puppies/rover.md. If not part of a collection, an empty string is returned.|
|page.tags|The list of tags to which this post belongs. These can be specified in the front matter.|
|page.dir|The path between the source directory and the file of the post or page, e.g. /pages/. This can be overridden by permalink in the front matter.|
|page.name|The filename of the post or page, e.g. about.md|
|page.path|The path to the raw post or page. Example usage: Linking back to the page or post’s source on GitHub. This can be overridden in the front matter.|
|page.next|The next post relative to the position of the current post in site.posts. Returns nil for the last entry.|
|page.previous|The previous post relative to the position of the current post in site.posts. Returns nil for the first entry.|

## 2.4  分页器Permalink
|VARIABLE	| DESCRIPTION|
|--             |-- |
|paginator.page|The number of the current page|
|paginator.per_page|Number of posts per page|
|paginator.posts|Posts available for the current page|
|paginator.total_posts|Total number of posts|
|paginator.total_pages|Total number of pages|
|paginator.previous_page|The number of the previous page, or nil if no previous page exists|
|paginator.previous_page_path|The path to the previous page, or nil if no previous page exists|
|paginator.next_page|The number of the next page, or nil if no subsequent page exists|
|paginator.next_page_path|The path to the next page, or nil if no subsequent page exists|

# 3. 常用指令
```
{% include footer.html %} <!--包含 _includes 文件夹中的 footer.html-->
{% include_relative somedir/footer.html %}  <!--包含 相对于当前文件的 somedir/footer.html-->

<!--当前文件定义变量-->
---
title: My page
my_variable: footer_company_a.html
---
{% if page.my_variable %}
  {% include {{ page.my_variable }} %}
{% endif %}


<!--include 参数-->
<!--_includes/note.html-->
<div markdown="span" class="alert alert-info" role="alert">
<i class="fa fa-info-circle"></i> <b>Note:</b>
{{ include.content }}
<a href="{{include.url}}">back</a>
</div>

<!--_post/nodepage.html-->
{% include note.html content="This is my sample note." url="http://jekyllrb.com" %}

<!--存储一个变量-->
{% capture download_note %}
The latest version of {{ site.product_name }} is now available.
{% endcapture %}
<!--使用存储的变量-->
{% include note.html content=download_note %}

```

# 4. 布局

```
<!--default.html-->
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>{{ page.title }}</title>
    <link rel="stylesheet" href="/css/style.css">
  </head>
  <body>
    <nav>
      <a href="/">Home</a>
      <a href="/blog/">Blog</a>
    </nav>
    <h1>{{ page.title }}</h1>
    <section>
      {{ content }}
    </section>
    <footer>
      &copy; to me
    </footer>
  </body>
</html>
```
继承 + 不见变量
```
<!--_layouts/post.html:-->
---
layout: default
city: San Francisco  变量

---
<p>{{ page.date }} - Written by {{ page.author }}</p> 
<p>{{ layout.city }}</p>
{{ content }}
```

# 5. 分类 Permalinks
```
<!--_post/2022-2-2-about.md-->
---
permalink: /about/
---

<!--_config.yml-->
permalink: /:categories/:year/:month/:day/:title:output_ext

<!--集合 :collection|:path|:name|:title|:output_ext-->-->
collections:
  my_collection:
    output: true
    permalink: /:collection/:name

Page

```