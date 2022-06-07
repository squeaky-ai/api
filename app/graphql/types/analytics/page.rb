# frozen_string_literal: true

module Types
  module Analytics
    class Page < Types::BaseObject
      graphql_name 'AnalyticsPage'

      field :url, String, null: false
      field :view_count, Integer, null: false
      field :view_percentage, Float, null: false
      field :unique_view_count, Integer, null: false
      field :unique_view_percentage, Float, null: false
      field :exit_rate_percentage, Float, null: false
      field :bounce_rate_percentage, Float, null: false
      field :average_duration, Integer, null: false
    end
  end
end
