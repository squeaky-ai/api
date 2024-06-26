# frozen_string_literal: true

module Resolvers
  module Admin
    class Sites < Resolvers::Base
      type Types::Admin::Sites, null: false

      argument :page, Integer, required: false, default_value: 1
      argument :size, Integer, required: false, default_value: 25
      argument :search, String, required: false, default_value: nil
      argument :sort, Types::Admin::SiteSort, required: false, default_value: 'created_at__desc'

      def resolve(page:, size:, search:, sort:)
        sites = ::Site
          .unscoped
          .includes(%i[teams users plan billing site_bundles_site])
          .page(page)
          .per(size)
          .order(order(sort))

        sites = search_by(sites, search)

        {
          items: sites,
          pagination: {
            page_size: size,
            total: sites.total_count,
            sort:
          }
        }
      end

      private

      def order(sort)
        sorts = {
          'created_at__asc' => 'created_at ASC',
          'created_at__desc' => 'created_at DESC',
          'name__asc' => 'name ASC',
          'name__desc' => 'name DESC'
        }
        sorts[sort]
      end

      def search_by(sites, search)
        return sites unless search.presence

        query = "%#{search.downcase}%"

        sites.where('LOWER(name) LIKE :query', query:)
      end
    end
  end
end
