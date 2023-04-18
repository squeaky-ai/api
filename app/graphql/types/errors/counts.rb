# typed: false
# frozen_string_literal: true

module Types
  module Errors
    class Counts < Types::BaseObject
      graphql_name 'ErrorsCounts'

      field :group_type, String, null: false
      field :group_range, Integer, null: false
      field :items, [Types::Errors::Count, { null: false }], null: false
    end
  end
end
