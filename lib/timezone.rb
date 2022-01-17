# frozen_string_literal: true

class Timezone
  # Taken from this wikipedia page:
  # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
  TIMEZONES = YAML.load_file(File.expand_path('../config/timezones.yml', __dir__))

  def self.get_country_code(timezone = '')
    return nil if timezone.nil? || timezone.empty?

    TIMEZONES[timezone]
  end
end
