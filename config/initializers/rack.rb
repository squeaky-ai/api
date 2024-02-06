# frozen_string_literal: true

require 'rack'

# TODO: Remove once Rack have published the partitioned cookie!

module Rack
  module Utils
    module_function

    def set_cookie_header(key, value) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      case value
      when Hash
        key = escape(key) unless value[:escape_key] == false

        domain  = "; domain=#{value[:domain]}"            if value[:domain]
        path    = "; path=#{value[:path]}"                if value[:path]
        max_age = "; max-age=#{value[:max_age]}"          if value[:max_age]
        expires = "; expires=#{value[:expires].httpdate}" if value[:expires]
        secure = '; secure'                               if value[:secure]
        httponly = '; httponly'                           if value.key?(:httponly) ? value[:httponly] : value[:http_only]
        same_site =
          case value[:same_site]
          when false, nil
            nil
          when :none, 'None', :None
            '; samesite=none'
          when :lax, 'Lax', :Lax
            '; samesite=lax'
          when true, :strict, 'Strict', :Strict
            '; samesite=strict'
          else
            raise ArgumentError, "Invalid :same_site value: #{value[:same_site].inspect}"
          end
        partitioned = '; partitioned' if value[:partitioned]
        value = value[:value]
      else
        key = escape(key)
      end

      value = [value] unless value.is_a?(Array)

      "#{key}=#{value.map { |v| escape v }.join('&')}#{domain}#{path}#{max_age}#{expires}#{secure}#{httponly}#{same_site}#{partitioned}"
    end
  end
end
