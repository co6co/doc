require 'tzinfo'

module Jekyll
  module TimezoneConverter
    def convert_to_timezone(time, timezone)
      begin
        tz = TZInfo::Timezone.get(timezone)
        tz.utc_to_local(time.utc)
      rescue StandardError => e
        puts "TimezoneConverter Error: #{e.message}"  
      end 
    end
  end
end

Liquid::Template.register_filter(Jekyll::TimezoneConverter)
