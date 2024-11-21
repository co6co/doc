require 'jekyll'
 
# 配置 Jekyll 环境
site = Jekyll::Site.new(Jekyll.configuration({}))
 
# 假设你有一个帖子的路径
post_path = '2024-02-22-隐藏内容gs.md'

# 创建 Jekyll::Document 实例
post = Jekyll::Document.new(post_path, collection: site.collections['posts'], site: site)

# 获取文章的标题和 URL
title = post.data['title']
puts "Title: #{title}"
url = post.url


puts "URL: #{url}"
