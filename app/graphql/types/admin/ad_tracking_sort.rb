# frozen_string_literal: true

module Types
  module Admin
    class AdTrackingSort < Types::BaseEnum
      graphql_name 'AdminAdTrackingSort'

      value 'user_created_at__asc'
      value 'user_created_at__desc'
      value 'site_created_at__asc'
      value 'site_created_at__desc'
      value 'site_verified_at__asc'
      value 'site_verified_at__desc'
    end
  end
end
