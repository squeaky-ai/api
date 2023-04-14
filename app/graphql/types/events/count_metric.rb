# typed: false
# frozen_string_literal: true

module Types
  module Events
    class CountMetric < Types::BaseObject
      graphql_name 'EventsCountMetric'

      field :id, ID, null: false
      field :count, Integer, null: false
      field :type, Types::Events::Type, null: false
    end
  end
end
