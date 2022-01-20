# frozen_string_literal: true

module Resolvers
  module Analytics
    class PageViews < Resolvers::Base
      type Types::Analytics::PageViews, null: false

      def resolve
        sql = <<-SQL
          SELECT
            v.date_key date_key,
            SUM(v.total_count) total_count,
            SUM(CASE v.total_count WHEN 1 THEN 0 ELSE 1 END) unique_count
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

        date_format, group_type, group_range = Charts.date_groups(object[:from_date], object[:to_date])

        variables = [
          date_format,
          object[:site_id],
          object[:from_date],
          object[:to_date],
          [Recording::ACTIVE, Recording::DELETED]
        ]

        {
          group_type:,
          group_range:,
          items: Sql.execute(sql, variables)
        }
      end
    end
  end
end
