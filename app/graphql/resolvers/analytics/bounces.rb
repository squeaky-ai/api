# frozen_string_literal: true

module Resolvers
  module Analytics
    class Bounces < Resolvers::Base
      type [Types::Analytics::Bounce, { null: false }], null: false

      argument :size, Integer, required: false, default_value: 5

      def resolve_with_timings(size:)
        # TODO: Replace with ClickHouse
        sql = <<-SQL
          SELECT
            x.url url,
            COALESCE((NULLIF(bounce_rate_count, 0)::float / view_count) * 100, 0) percentage
          FROM (
            SELECT
              url,
              (count(*))::numeric view_count,
              (COUNT(exited_on) FILTER(WHERE bounced_on = true))::numeric bounce_rate_count
            FROM pages
            WHERE
              pages.site_id = ? AND
              to_timestamp(pages.exited_at / 1000)::date BETWEEN ? AND ?
            GROUP BY url
          ) as x
          ORDER BY percentage DESC
          LIMIT ?
        SQL

        variables = [
          object.site.id,
          object.range.from,
          object.range.to,
          size
        ]

        Sql.execute(sql, variables).map do |row|
          {
            url: row['url'],
            percentage: row['percentage']
          }
        end
      end
    end
  end
end
