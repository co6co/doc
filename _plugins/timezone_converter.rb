require 'tzinfo'

module Jekyll
  module TimezoneConverter
    def convert_to_timezone(time, timezone)
      tz = TZInfo::Timezone.get(timezone)
      tz.utc_to_local(time.utc)
    end
  end
end

Liquid::Template.register_filter(Jekyll::TimezoneConverter)
