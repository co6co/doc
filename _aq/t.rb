require 'tzinfo'
require 'yaml'
require 'time'

# 获取特定时区对象
shanghai = TZInfo::Timezone.get('Asia/Shanghai')

# 获取当前时间
now = Time.now
puts now
local_time = shanghai.utc_to_local(now)
puts local_time
#=begin
 

puts shanghai.inspect
#=end

yaml_string = "
---
layout: post
title: 测试
layout: post 
categories: [临时3+++++++++++++++++++++++++++++]
tags: [测试]
keywords: 测试
description: 第一
date: 2024-02-22 16:26:01
--- 
"

begin
  time = YAML.safe_load(yaml_string, permitted_classes: [Time])
  puts time.class  # 输出: Time
  puts time        # 输出: 2023-11-21 14:44:00 +0800
rescue Psych::DisallowedClass => e
  puts "Error: #{e.message}"
end
