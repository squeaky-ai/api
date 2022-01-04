# frozen_string_literal: true

module Types
  module Analytics
    class PageViews < Types::BaseObject
      graphql_name 'AnalyticsPageViews'

      field :total, Integer, null: false
      field :unique, Integer, null: false
      field :timestamp, GraphQL::Types::ISO8601DateTime, null: false
    end
  end
end
