# frozen_string_literal: true

module Types
  module Analytics
    class Visitor < Types::BaseObject
      graphql_name 'AnalyticsVisitor'

      field :new, Boolean, null: true
      field :timestamp, GraphQL::Types::ISO8601DateTime, null: false
    end
  end
end
