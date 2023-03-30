# frozen_string_literal: true

module Resolvers
  module Analytics
    class Dimensions < Resolvers::Base
      type [Types::Analytics::Dimension, { null: false }], null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT
            DISTINCT(ROUND(device_x, -1)) grouped_device_x,
            COUNT(*) count
          FROM
            recordings
          WHERE
            device_x > 0 AND
            site_id = :site_id AND
            toDate(disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
          GROUP BY
            grouped_device_x
        SQL

        variables = {
          site_id: object.site.id,
          timezone: object.range.timezone,
          from_date: object.range.from,
          to_date: object.range.to
        }

        results = Sql::ClickHouse.select_all(sql, variables)

        results.map do |result|
          {
            device_x: result['grouped_device_x'],
            count: result['count']
          }
        end
      end
    end
  end
end
