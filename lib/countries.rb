# frozen_string_literal: true

class Countries
  # Taken from this wikipedia page:
  # https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes
  COUNTRIES = YAML.load_file(File.expand_path('../config/countries.yml', __dir__))

  def self.get_country(country_code = '')
    return nil if country_code.nil? || country_code.empty?

    COUNTRIES[country_code]
  end
end
