# typed: false
# frozen_string_literal: true

module Types
  module Analytics
    class VisitAt < Types::BaseObject
      graphql_name 'AnalyticsVisitAt'

      field :day, String, null: false
      field :hour, Integer, null: false
      field :count, Integer, null: false
    end
  end
end
