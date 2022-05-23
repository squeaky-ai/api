# frozen_string_literal: true

module Resolvers
  module Analytics
    class PageViews < Resolvers::Base
      type Types::Analytics::PageViews, null: false

      def resolve
        date_format, group_type, group_range = Charts.date_groups(object[:from_date], object[:to_date])
        trend_date_range = Trend.offset_period(object[:from_date], object[:to_date])

        current_page_views = page_views(date_format, object[:site_id], object[:from_date], object[:to_date])
        previous_page_views = page_views(date_format, object[:site_id], *trend_date_range)

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

      def page_views(date_format, site_id, from_date, to_date)
        sql = <<-SQL
          SELECT
            v.date_key date_key,
            SUM(v.total_count) count
          FROM (
            SELECT
              COUNT(pages.id) total_count,
              to_char(to_timestamp(disconnected_at / 1000), ?) date_key
            FROM pages
            INNER JOIN recordings ON recordings.id = pages.recording_id
            WHERE recordings.site_id = ? AND to_timestamp(pages.exited_at / 1000)::date BETWEEN ? AND ? AND recordings.status IN (?)
            GROUP BY recordings.id
          ) v
          GROUP BY v.date_key;
        SQL

        variables = [
          date_format,
          site_id,
          from_date,
          to_date,
          [Recording::ACTIVE, Recording::DELETED]
        ]

        Sql.execute(sql, variables)
      end
    end
  end
end
