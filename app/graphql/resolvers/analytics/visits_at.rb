# frozen_string_literal: true

module Resolvers
  module Analytics
    class VisitsAt < Resolvers::Base
      type [Types::Analytics::VisitAt, { null: false }], null: false

      def resolve_with_timings # rubocop:disable Metrics/AbcSize
        # TODO: Replace with ClickHouse
        sql = <<-SQL
          SELECT
            formatDateTime(toDateTime(disconnected_at / 1000), '%u,%H') day_hour,
            COUNT(*) count
          FROM
            recordings
          WHERE
            site_id = ? AND
            toDate(disconnected_at / 1000)::date BETWEEN ? AND ?
          GROUP BY
            day_hour;
        SQL

        variables = [
          object.site.id,
          object.range.from,
          object.range.to
        ]

        results = Sql::ClickHouse.select_all(sql, variables)

        results.map do |r|
          day, hour = r['day_hour'].split(',')

          # ClickHouse works Mon-Sun and Rails works Sun-Sat
          days = Date::ABBR_DAYNAMES.dup
          days.push(days.shift)

          {
            day: days[day.to_i - 1],
            hour: hour.to_i - 1,
            count: r['count']
          }
        end
      end
    end
  end
end
