# frozen_string_literal: true

module Resolvers
  module Analytics
    class VisitsAt < Resolvers::Base
      type [Types::Analytics::VisitAt, { null: false }], null: false

      def resolve
        sql = <<-SQL.squish
          SELECT
            formatDateTime(toDateTime(disconnected_at / 1000, :timezone), '%u,%H') day_hour,
            COUNT(*) count
          FROM
            recordings
          WHERE
            site_id = :site_id AND
            toDate(disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
          GROUP BY
            day_hour;
        SQL

        variables = {
          site_id: object.site.id,
          timezone: object.range.timezone,
          from_date: object.range.from,
          to_date: object.range.to
        }

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
