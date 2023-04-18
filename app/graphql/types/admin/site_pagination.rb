# typed: false
# frozen_string_literal: true

module Types
  module Admin
    class SitePagination < Types::BaseObject
      graphql_name 'AdminSitePagination'

      field :page_size, Integer, null: false
      field :total, Integer, null: false
      field :sort, Types::Admin::SiteSort, null: false
    end
  end
end
