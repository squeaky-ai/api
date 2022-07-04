# frozen_string_literal: true

module Resolvers
  module Analytics
    class PageViews < Resolvers::Base
      type Types::Analytics::PageViews, null: false

      def resolve_with_timings
        date_format, group_type, group_range = Charts.date_groups(object.range.from, object.range.to)

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
            v.date_key date_key,
            SUM(v.total_count) count
          FROM (
            SELECT
              COUNT(pages.id) total_count,
              to_char(to_timestamp(pages.exited_at / 1000), ?) date_key
            FROM pages
            WHERE pages.site_id = ? AND to_timestamp(pages.exited_at / 1000)::date BETWEEN ? AND ?
            GROUP BY pages.id
          ) v
          GROUP BY v.date_key;
        SQL

        variables = [
          date_format,
          object.site.id,
          from_date,
          to_date
        ]

        Sql.execute(sql, variables)
      end
    end
  end
end
