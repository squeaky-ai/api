# frozen_string_literal: true

module Types
  module Analytics
    class Recording < Types::BaseObject
      graphql_name 'AnalyticsRecording'

      field :date_key, String, null: false
      field :count, Integer, null: false
    end
  end
end
