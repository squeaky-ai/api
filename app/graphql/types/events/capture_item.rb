# frozen_string_literal: true

module Types
  module Events
    class CaptureItem < Types::BaseObject
      graphql_name 'EventsCaptureItem'

      field :id, ID, null: false
      field :name, String, null: false
      field :type, Integer, null: false
      field :rules, [Events::Rule, { null: false }], null: false
      field :count, Integer, null: false
      field :group_ids, [String, { null: false }], null: false
      field :group_names, [String, { null: false }], null: false
      field :source, String, null: true
      field :last_counted_at, GraphQL::Types::ISO8601DateTime, null: true
    end
  end
end
