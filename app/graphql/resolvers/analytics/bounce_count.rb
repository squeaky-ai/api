# frozen_string_literal: true

module Resolvers
  module Analytics
    class BounceCount < Resolvers::Base
      type Types::Analytics::BounceCounts, null: false

      def resolve
        sql = <<-SQL.squish
          SELECT
            COUNT(*) view_count,
            COUNT(exited_on) FILTER(WHERE bounced_on = true) bounce_rate_count,
            formatDateTime(toDate(exited_at / 1000, :timezone), :date_format) date_key
          FROM
            page_events
          WHERE
            site_id = :site_id AND
            toDate(exited_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
          GROUP BY date_key
        SQL

        date_format, group_type, group_range = Charts.date_groups(object.range.from, object.range.to, clickhouse: true)

        variables = {
          date_format:,
          site_id: object.site.id,
          timezone: object.range.timezone,
          from_date: object.range.from,
          to_date: object.range.to
        }

        {
          group_type:,
          group_range:,
          items: Sql::ClickHouse.select_all(sql, variables)
        }
      end
    end
  end
end
