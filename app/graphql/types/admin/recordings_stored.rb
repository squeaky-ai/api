# typed: false
# frozen_string_literal: true

module Types
  module Admin
    class RecordingsStored < Types::BaseObject
      graphql_name 'AdminRecordingsStored'

      field :count, Integer, null: false
      field :date, GraphQL::Types::ISO8601Date, null: false
    end
  end
end
