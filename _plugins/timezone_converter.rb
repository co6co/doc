require 'tzinfo'

module Jekyll
  module TimezoneConverter
    def convert_to_timezone(time, timezone)
      begin
        tz = TZInfo::Timezone.get(timezone)
        tz.utc_to_local(time.utc)
      rescue StandardError => e
        puts "标准错误: #{e.message}" 
      ensure 
        puts time
      end
     
    end
  end
end

Liquid::Template.register_filter(Jekyll::TimezoneConverter)
