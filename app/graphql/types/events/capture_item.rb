# frozen_string_literal: true

module Types
  module Events
    class CaptureItem < Types::BaseObject
      graphql_name 'EventsCaptureItem'

      field :id, ID, null: false
      field :name, String, null: false
      field :type, Integer, null: false
      field :rules, [Events::Rule, { null: true }], null: false
      field :count, Integer, null: false
      field :last_counted_at, GraphQL::Types::ISO8601DateTime, null: true
    end
  end
end
