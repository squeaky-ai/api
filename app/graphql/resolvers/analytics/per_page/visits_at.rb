# typed: false
# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
      class VisitsAt < Resolvers::Base
        type [Types::Analytics::VisitAt, { null: false }], null: false

        def resolve_with_timings # rubocop:disable Metrics/AbcSize
          sql = <<-SQL
            SELECT
              formatDateTime(toDateTime(recordings.disconnected_at / 1000, :timezone), '%u,%H') day_hour,
              COUNT(*) count
            FROM
              recordings
            INNER JOIN
              page_events on page_events.recording_id = recordings.recording_id
            WHERE
              recordings.site_id = :site_id AND
              toDate(recordings.disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date AND
              like(page_events.url, :url)
            GROUP BY
              day_hour;
          SQL

          variables = {
            site_id: object.site.id,
            timezone: object.range.timezone,
            from_date: object.range.from,
            to_date: object.range.to,
            url: Paths.replace_route_with_wildcard(object.page)
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
end
