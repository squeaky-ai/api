# typed: false
# frozen_string_literal: true

module Resolvers
  module Analytics
    class Devices < Resolvers::Base
      type [Types::Analytics::Device, { null: false }], null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT
            COUNT(device_type) FILTER(WHERE device_type = 'Computer') desktop_count,
            COUNT(device_type) FILTER(WHERE device_type = 'Mobile') mobile_count
          FROM
            recordings
          WHERE
            site_id = :site_id AND
            toDate(disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
        SQL

        variables = {
          site_id: object.site.id,
          timezone: object.range.timezone,
          from_date: object.range.from,
          to_date: object.range.to
        }

        results = Sql::ClickHouse.select_all(sql, variables).first

        [
          {
            type: 'mobile',
            count: results['mobile_count']
          },
          {
            type: 'desktop',
            count: results['desktop_count']
          }
        ]
      end
    end
  end
end
