module Jekyll
    class MultiPostsGenerator < Generator
      safe true
  
      def generate(site)
        # 定义要读取的文章目录
        additional_posts_dirs = ['_post', '_aq']
  
        additional_posts_dirs.each do |dir|
          Dir.glob(File.join(site.source, dir, '*')).each do |file|
            next unless File.file?(file)
  
            doc = Jekyll::Document.new(file, {
              :site => site,
              :collection => site.collections['posts']
            })
            site.posts.docs << doc
          end
        end
      end
    end
  end
