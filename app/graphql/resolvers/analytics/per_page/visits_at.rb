# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
      class VisitsAt < Resolvers::Base
        type [Types::Analytics::VisitAt, { null: false }], null: false

        def resolve_with_timings # rubocop:disable Metrics/AbcSize
          sql = <<-SQL
            SELECT
              formatDateTime(toDateTime(recordings.disconnected_at / 1000), '%u,%H') day_hour,
              COUNT(*) count
            FROM
              recordings
            INNER JOIN
              page_events on page_events.recording_id = recordings.recording_id
            WHERE
              recordings.site_id = ? AND
              toDate(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
              page_events.url = ?
            GROUP BY
              day_hour;
          SQL

          variables = [
            object.site.id,
            object.range.from,
            object.range.to,
            object.page
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
end
