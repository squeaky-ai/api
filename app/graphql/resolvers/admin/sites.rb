# frozen_string_literal: true

module Resolvers
  module Admin
    class Sites < Resolvers::Base
      type Types::Admin::Sites, null: false

      argument :page, Integer, required: false, default_value: 1
      argument :size, Integer, required: false, default_value: 25
      argument :search, String, required: false, default_value: nil
      argument :sort, Types::Admin::SiteSort, required: false, default_value: 'created_at__desc'

      def resolve_with_timings(page:, size:, search:, sort:)
        sites = ::Site
                .includes(%i[teams users])
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
          'created_at__desc' => 'created_at DESC'
        }
        sorts[sort]
      end

      def search_by(sites, search)
        return sites unless search

        query = "%#{search}%"

        sites.where('name ILIKE :query', query:)
      end
    end
  end
end
