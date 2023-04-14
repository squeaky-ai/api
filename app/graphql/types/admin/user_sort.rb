# typed: false
# frozen_string_literal: true

module Types
  module Admin
    class UserSort < Types::BaseEnum
      graphql_name 'AdminUserSort'

      value 'created_at__asc'
      value 'created_at__desc'
      value 'last_activity_at__asc'
      value 'last_activity_at__desc'
      value 'name__asc'
      value 'name__desc'
    end
  end
end
