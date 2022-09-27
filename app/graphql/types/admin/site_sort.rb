# frozen_string_literal: true

module Types
  module Admin
    class SiteSort < Types::BaseEnum
      graphql_name 'AdminSiteSort'

      value 'created_at__asc'
      value 'created_at__desc'
    end
  end
end
