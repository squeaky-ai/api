# typed: false
# frozen_string_literal: true

module Types
  module Errors
    class Pagination < Types::BaseObject
      graphql_name 'ErrorsPagination'

      field :page_size, Integer, null: false
      field :total, Integer, null: false
      field :sort, Types::Errors::Sort, null: false
    end
  end
end
