# frozen_string_literal: true

module Resolvers
  module Consent
    class Translations < Resolvers::Base
      type String, null: false

      argument :user_locale, String, required: true

      def resolve_with_timings(user_locale:)
        locale = locale(user_locale)

        I18n.with_locale(locale) { translations.to_json }
      end

      private

      def locale(user_locale)
        if object.languages.include?(user_locale)
          user_locale
        else
          object.languages_default
        end
      end

      def translations
        {
          privacy_friendly_analytics: I18n.t(:privacy_friendly_analytics),
          we_use_squeaky: I18n.t(:we_use_squeaky, name: object.name),
          set_consent_preferemces: I18n.t(:set_consent_preferemces),
          what_makes_squeaky_different: I18n.t(:what_makes_squeaky_different),
          no_cookies: I18n.t(:no_cookies),
          never_sold: I18n.t(:never_sold),
          data_capture_features: I18n.t(:data_capture_features),
          visitors_are_anonymous: I18n.t(:visitors_are_anonymous),
          data_in_eu: I18n.t(:data_in_eu),
          accept: I18n.t(:accept),
          reject: I18n.t(:reject)
        }
      end
    end
  end
end
