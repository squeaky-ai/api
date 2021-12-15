# frozen_string_literal: true

# Helper class for mapping locales to languages
class Locale
  LOCALES = YAML.load_file(File.expand_path('../config/languages.yml', __dir__))

  DEFAULT = 'Unknown'

  def self.get_language(locale = '')
    return DEFAULT if locale.nil? || locale.empty?

    key = locale.downcase.sub('-', '_')
    LOCALES[key] || DEFAULT
  end

  def self.get_locale(language = '')
    return DEFAULT if language.nil? || language.empty?

    result = LOCALES.find { |_k, v| v == language }.first
    (result || DEFAULT).sub('_', '-')
  end
end
