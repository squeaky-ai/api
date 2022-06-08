# frozen_string_literal: true

module Types
  module Events
    class HistoryStat < Types::BaseObject
      graphql_name 'EventsHistoryStat'

      field :id, ID, null: false
      field :name, String, null: false
      field :type, Types::Events::HistoryType, null: false
      field :count, Integer, null: false
      field :average_events_per_visitor, Integer, null: false
    end
  end
end
