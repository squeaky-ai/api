# frozen_string_literal: true

module Resolvers
  module Analytics
    class BounceCount < Resolvers::Base
      type Types::Analytics::BounceCounts, null: false

      def resolve_with_timings # rubocop:disable Metrics/AbcSize
        # TODO: Replace with ClickHouse
        sql = <<-SQL
          SELECT
            (count(*))::numeric view_count,
            (COUNT(exited_on) FILTER(WHERE bounced_on = true))::numeric bounce_rate_count,
            to_char(to_timestamp(pages.exited_at / 1000)::date, ?) date_key
          FROM pages
          WHERE
            pages.site_id = ? AND
            to_timestamp(pages.exited_at / 1000)::date BETWEEN ? AND ?
          GROUP BY date_key
        SQL

        date_format, group_type, group_range = Charts.date_groups(object.range.from, object.range.to)

        variables = [
          date_format,
          object.site.id,
          object.range.from,
          object.range.to
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
