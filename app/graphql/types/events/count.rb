# frozen_string_literal: true

module Types
  module Events
    class Count < Types::BaseObject
      graphql_name 'EventsCount'

      field :date_key, String, null: false
      field :metrics, [Types::Events::CountMetric, { null: true }], null: false
    end
  end
end
