# typed: false
# frozen_string_literal: true

module Types
  module Errors
    class Count < Types::BaseObject
      graphql_name 'ErrorsCount'

      field :date_key, String, null: false
      field :count, Integer, null: false
    end
  end
end
