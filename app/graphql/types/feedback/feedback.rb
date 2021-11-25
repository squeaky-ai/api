# frozen_string_literal: true

module Types
  module Feedback
    class Feedback < Types::BaseObject
      graphql_name 'Feedback'

      field :nps_enabled, Boolean, null: false
      field :nps_accent_color, String, null: true
      field :nps_schedule, String, null: true
      field :nps_phrase, String, null: true
      field :nps_follow_up_enabled, Boolean, null: true
      field :nps_contact_consent_enabled, Boolean, null: true
      field :nps_layout, String, null: true

      field :sentiment_enabled, Boolean, null: true
      field :sentiment_accent_color, String, null: true
      field :sentiment_excluded_pages, [String, { null: true }], null: false
      field :sentiment_layout, String, null: true
    end
  end
end
