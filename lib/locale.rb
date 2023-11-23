# frozen_string_literal: true

# Helper class for mapping locales to languages
class Locale
  DEFAULT = 'Unknown'

  def self.get_language(locale = '')
    return DEFAULT if locale.blank?

    key = locale.downcase.sub('-', '_')
    Rails.configuration.languages[key.to_sym] || DEFAULT
  end

  def self.get_locale(language = '')
    return DEFAULT if language.blank?

    result = Rails.configuration.languages.find { |_k, v| v == language }&.first
    (result || DEFAULT).to_s.sub('_', '-')
  end
end
