# frozen_string_literal: true

module Resolvers
  module Analytics
    class PageViews < Resolvers::Base
      type Types::Analytics::PageViews, null: false

      def resolve_with_timings
        date_format, group_type, group_range = Charts.date_groups(object.range.from, object.range.to, clickhouse: true)

        current_page_views = page_views(date_format, object.range.from, object.range.to)
        previous_page_views = page_views(date_format, object.range.trend_from, object.range.trend_to)

        current_total = sum_of_page_views(current_page_views)
        previous_total = sum_of_page_views(previous_page_views)

        {
          group_type:,
          group_range:,
          total: current_total,
          trend: current_total - previous_total,
          items: current_page_views
        }
      end

      private

      def sum_of_page_views(page_views)
        page_views.reduce(0) { |count, page| count + page['count'] }
      end

      def page_views(date_format, from_date, to_date)
        sql = <<-SQL
          SELECT
            COUNT(*) count,
            formatDateTime(toDateTime(exited_at / 1000, :timezone), :date_format) date_key
          FROM
            page_events
          WHERE
            site_id = :site_id AND
            toDate(exited_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
          GROUP BY date_key
          ORDER BY date_key ASC
        SQL

        variables = {
          date_format:,
          site_id: object.site.id,
          timezone: object.range.timezone,
          from_date:,
          to_date:
        }

        Sql::ClickHouse.select_all(sql, variables)
      end
    end
  end
end
