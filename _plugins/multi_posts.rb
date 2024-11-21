require 'yaml'
require 'time'
module Jekyll
    class MultiPostsGenerator < Generator
      safe true 
      def _category(site,doc,categorys)
        #puts "categories :#{site.categories}"
        categorys.each do |category|
          flag=0
          site.categories.each do |c,v|
            if category==c
              flag=1
              v << doc
            end  
          end
          if flag==0
            site.categories[category]=[doc]
          end    
        end 
      end
      def _tag(site,doc,tags) 
        tags.each do |tag|
          flag=0
          site.tags.each do |c,v|
            if tag==c
              flag=1
              v << doc
            end  
          end
          if flag==0
            site.tags[tag]=[doc]
          end    
        end 
      end 
      def generate(site)
        additional_posts_dirs = ['aq','old']
        additional_posts_dirs.each do| dir |
          site.collections[dir].docs .each do |p|
            _category(site,p,p.categories)
            _tag(site,p,p.tags)
          end
        end
      end
      def generate2(site)
        # 暂时不是
        # 定义要读取的文章目录
        additional_posts_dirs = {'_aq'=>"安全" }
        puts "Site :#{site.source}" 
        additional_posts_dirs.each do |dir,category|
          Dir.glob(File.join(site.source, dir, '**/*.md')).each do |file|
            begin
              puts "处理文件：#{dir} #{file}..."
              next unless File.file?(file)
              
              #site.collections['posts'].each do | p |
              #  begin
              #    puts "title #{p.title}"
              #  rescue StandardError => e
              #    puts "title Error Error: #{p}"  
              #  end  
              #end
              # 读取文件内容并解析 Front Matter
              content = File.read(file)

              pageData = YAML.safe_load(content.match(/---\s*\n(.*?)(?:\n---)/m)[1],permitted_classes: [Time])
              # 添加类别到 Front Matter 
              pageData['categories'] ||= []
              # 增加其他类别
              pageData['categories'] << category 

              #puts "处理文件：Data #{pageData['categories']}"
              #doc = Jekyll::Document.new(file,  
              #  site: site, 
              #  collection: site.collections['posts'] 
              # )  
              #title = doc.data['title']
              #url = doc.url
              #puts "Title: #{title}"
              #puts "URL: #{url}"
             
              _category(site,doc,pageData['categories'])
              # 将新文档添加到站点的帖子列表中
              #site.posts.docs << doc
            rescue StandardError => e
              puts puts "处理文件：#{dir} #{file}出错：#{e}"
            end
          end
        end
      end
    end
  end
