# frozen_string_literal: true

module Types
  module Events
    class Group < Types::BaseObject
      graphql_name 'EventsGroup'

      field :id, ID, null: false
      field :name, String, null: false
      field :items, [Events::Capture, { null: true }], null: false
    end
  end
end
