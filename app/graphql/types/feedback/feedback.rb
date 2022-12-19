# frozen_string_literal: true

module Types
  module Feedback
    class Feedback < Types::BaseObject
      graphql_name 'Feedback'

      field :id, ID, null: false

      field :nps_enabled, Boolean, null: false
      field :nps_accent_color, String, null: true
      field :nps_schedule, String, null: true
      field :nps_phrase, String, null: true
      field :nps_follow_up_enabled, Boolean, null: true
      field :nps_contact_consent_enabled, Boolean, null: true
      field :nps_layout, String, null: true
      field :nps_excluded_pages, [String, { null: false }], null: false
      field :nps_languages, [String, { null: false }], null: false
      field :nps_languages_default, String, null: true
      field :nps_hide_logo, Boolean, null: false

      field :sentiment_enabled, Boolean, null: true
      field :sentiment_accent_color, String, null: true
      field :sentiment_excluded_pages, [String, { null: false }], null: false
      field :sentiment_layout, String, null: true
      field :sentiment_devices, [String, { null: false }], null: false
      field :sentiment_hide_logo, Boolean, null: false
      field :sentiment_schedule, String, null: true
      field :sentiment_languages, [String, { null: false }], null: false
      field :sentiment_languages_default, String, null: true
    end
  end
end
