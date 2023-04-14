# typed: false
# frozen_string_literal: true

module Types
  module Events
    class Counts < Types::BaseObject
      graphql_name 'EventsCounts'

      field :group_type, String, null: false
      field :group_range, Integer, null: false
      field :items, [Types::Events::Count, { null: false }], null: false
    end
  end
end
