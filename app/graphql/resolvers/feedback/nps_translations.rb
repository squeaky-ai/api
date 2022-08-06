# frozen_string_literal: true

module Resolvers
  module Feedback
    class NpsTranslations < Resolvers::Base
      type String, null: false

      argument :user_locale, String, required: true

      def resolve_with_timings(user_locale:)
        locale = locale(user_locale)

        I18n.with_locale(locale) { translations.to_json }
      end

      private

      def locale(user_locale)
        if object.nps_languages.include?(user_locale)
          user_locale
        else
          object.nps_languages_default
        end
      end

      def translations
        {
          how_likely_to_recommend: I18n.t(:how_likely_to_recommend, name: object.nps_phrase),
          not_likely: I18n.t(:not_likely),
          extremely_likely: I18n.t(:extremely_likely),
          what_is_the_main_reason: I18n.t(:what_is_the_main_reason),
          would_you_like_to_hear: I18n.t(:would_you_like_to_hear),
          yes: I18n.t(:yes),
          no: I18n.t(:no),
          email_address: I18n.t(:email_address),
          submit: I18n.t(:submit),
          feedback_sent: I18n.t(:feedback_sent),
          thanks_for_sharing: I18n.t(:thanks_for_sharing),
          close: I18n.t(:close),
          powered_by: I18n.t(:powered_by),
          please_type: I18n.t(:please_type)
        }
      end
    end
  end
end
