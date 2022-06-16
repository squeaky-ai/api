# frozen_string_literal: true

module Types
  module Events
    class Stat < Types::BaseObject
      graphql_name 'EventsStat'

      field :id, ID, null: false
      field :name, String, null: false
      field :type, Types::Events::Type, null: false
      field :count, Integer, null: false
      field :average_events_per_visitor, Float, null: false
    end
  end
end
