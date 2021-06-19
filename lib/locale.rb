# frozen_string_literal: true

# Helper class for mapping locales to languages
class Locale
  LOCALES = YAML.load_file(File.expand_path('../config/languages.yml', __dir__))

  def self.get_language(locale = '')
    key = locale.downcase.sub('-', '_')
    LOCALES[key] || 'Unknown'
  end
end
