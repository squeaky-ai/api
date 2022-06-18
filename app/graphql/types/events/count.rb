# frozen_string_literal: true

module Types
  module Events
    class Count < Types::BaseObject
      graphql_name 'EventsCount'

      field :id, ID, null: false
      field :date_key, String, null: false
      field :type, Types::Events::Type, null: false
      field :count, Integer, null: false
    end
  end
end
