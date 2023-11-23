# frozen_string_literal: true

class Timezone
  def self.get_country_code(timezone = '')
    return nil if timezone.blank?

    Rails.configuration.timezones[timezone.to_sym]
  end
end
