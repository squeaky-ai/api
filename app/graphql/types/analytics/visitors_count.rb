# typed: false
# frozen_string_literal: true

module Types
  module Analytics
    class VisitorsCount < Types::BaseObject
      graphql_name 'AnalyticsVisitorsCount'

      field :total, Integer, null: false
      field :new, Integer, null: false
    end
  end
end
