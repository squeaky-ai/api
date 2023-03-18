# frozen_string_literal: true

module Types
  module Exports
    class DataExport < Types::BaseObject
      graphql_name 'DataExport'

      field :id, ID, null: false
      field :filename, String, null: false
      field :export_type, Integer, null: false
      field :exported_at, GraphQL::Types::BigInt, null: true
      field :start_date, GraphQL::Types::ISO8601Date, null: false
      field :end_date, GraphQL::Types::ISO8601Date, null: false
    end
  end
end
