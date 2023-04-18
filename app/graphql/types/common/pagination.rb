# frozen_string_literal: true

module Types
  module Common
    class Pagination < Types::BaseObject
      graphql_name 'CommonPagination'

      field :page_size, Integer, null: false
      field :total, Integer, null: false
    end
  end
end
