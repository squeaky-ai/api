# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
      class VisitsAt < Resolvers::Base
        type [Types::Analytics::VisitAt, { null: false }], null: false

        def resolve_with_timings # rubocop:disable Metrics/AbcSize
          # TODO: Replace with ClickHouse
          sql = <<-SQL
            SELECT to_char(to_timestamp(disconnected_at / 1000), 'Dy,HH24') day_hour, COUNT(*)
            FROM recordings
            INNER JOIN pages on pages.recording_id = recordings.id
            WHERE
              recordings.site_id = ? AND
              to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
              pages.url = ?
            GROUP BY day_hour;
          SQL

          variables = [
            object.site.id,
            object.range.from,
            object.range.to,
            object.page
          ]

          results = Sql.execute(sql, variables)

          results.map do |r|
            day, hour = r['day_hour'].split(',')

            {
              day: day.strip,
              hour: hour.to_i,
              count: r['count']
            }
          end
        end
      end
    end
  end
end
