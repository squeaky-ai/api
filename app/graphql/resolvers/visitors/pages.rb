# frozen_string_literal: true

module Resolvers
  module Visitors
    class Pages < Resolvers::Base
      type Types::Visitors::Pages, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 10
      argument :sort, Types::Visitors::PagesSort, required: false, default_value: 'views_count__desc'

      def resolve_with_timings(page:, size:, sort:)
        order = order_by(sort)

        pages = Visitor
                .find(object.id)
                .pages
                .select('url, count(*) count')
                .group(:url)
                .order(order)
                .page(page)
                .per(size)

        {
          items: map_results(pages),
          pagination: pagination(arguments, pages, size)
        }
      end

      def pagination(arguments, pages, size)
        {
          page_size: size,
          total: pages.total_count,
          sort: arguments[:sort]
        }
      end

      private

      def map_results(pages)
        pages.to_a.map do |page|
          {
            page_view: page.url,
            page_view_count: page.count,
            average_time_on_page: 0
          }
        end
      end

      def order_by(sort)
        orders = {
          'views_count__desc' => 'count DESC',
          'views_count__asc' => 'count ASC'
        }

        Arel.sql(orders[sort] || orders['views_count__desc'])
      end
    end
  end
end
