# typed: false
# frozen_string_literal: true

class Countries
  def self.get_country(country_code = '')
    return nil if country_code.nil? || country_code.empty?

    Rails.configuration.countries[country_code.to_sym] || 'Unknown'
  end
end
