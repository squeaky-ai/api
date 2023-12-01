# frozen_string_literal: true

module Types
  module Common
    class StringRecord < Types::BaseObject
      graphql_name 'StringRecord'

      field :key, String, null: false
      field :value, String, null: false
    end
  end
end
