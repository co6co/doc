
Dir.glob(File.join('H:/Work/Projects/github/doc', '_old',"**/*.md") ).each do |file|
  puts "处理文件 #{file}..." 
end


additional_posts_dirs = {
  '_my_posts1' => 'category1',
  '_my_posts2' => 'category2'
}
additional_posts_dirs.each do |dir, category|
  puts "处理文件 #{dir} #{category}..." 
end
