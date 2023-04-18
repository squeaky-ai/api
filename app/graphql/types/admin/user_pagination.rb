# frozen_string_literal: true

module Types
  module Admin
    class UserPagination < Types::BaseObject
      graphql_name 'AdminUserPagination'

      field :page_size, Integer, null: false
      field :total, Integer, null: false
      field :sort, Types::Admin::UserSort, null: false
    end
  end
end
