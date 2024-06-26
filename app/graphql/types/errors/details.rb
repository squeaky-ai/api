# frozen_string_literal: true

module Types
  module Errors
    class Details < Types::BaseObject
      graphql_name 'ErrorsDetails'

      field :id, ID, null: false
      field :message, String, null: false
      field :stack, String, null: false
      field :pages, [String, { null: false }], null: false
      field :filename, String, null: false
      field :line_number, Integer, null: false
      field :col_number, Integer, null: false
    end
  end
end
