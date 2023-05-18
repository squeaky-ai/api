# frozen_string_literal: true

module Resolvers
  module Visitors
    class Pages < Resolvers::Base
      type Types::Visitors::Pages, null: false

      argument :page, Integer, required: false, default_value: 1
      argument :size, Integer, required: false, default_value: 10
      argument :sort, Types::Visitors::PagesSort, required: false, default_value: 'views_count__desc'

      def resolve_with_timings(page:, size:, sort:)
        pages = pages(size, page, sort)

        {
          items: pages,
          pagination: pagination(size, sort)
        }
      end

      def pagination(size, sort)
        {
          page_size: size,
          total: pages_count,
          sort:
        }
      end

      private

      def pages(size, page, sort)
        sql = <<-SQL
          SELECT
            url page_view,
            COUNT(*) page_view_count,
            AVG(activity_duration) average_time_on_page
          FROM
            page_events
          WHERE
            site_id = :site_id AND
            visitor_id = :visitor_id
          GROUP BY url
          ORDER BY #{order_by(sort)}
          LIMIT :limit
          OFFSET :offset
        SQL

        variables = {
          site_id: object.site_id,
          visitor_id: object.id,
          limit: size,
          offset: (size * (page - 1))
        }

        Sql::ClickHouse.select_all(sql, variables)
      end

      def pages_count
        sql = <<-SQL
          SELECT COUNT(*)
          FROM (
            SELECT COUNT(*)
            FROM
              page_events
            WHERE
              site_id = :site_id AND
              visitor_id = :visitor_id
            GROUP BY url
          )
        SQL

        variables = {
          site_id: object.site_id,
          visitor_id: object.id
        }

        Sql::ClickHouse.select_value(sql, variables) || 0
      end

      def order_by(sort)
        orders = {
          'views_count__desc' => 'page_view_count DESC',
          'views_count__asc' => 'page_view_count ASC',
          'average_time_on_page__desc' => 'average_time_on_page DESC',
          'average_time_on_page__asc' => 'average_time_on_page ASC'
        }

        orders[sort]
      end
    end
  end
end
