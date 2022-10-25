# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
      class Dimensions < Resolvers::Base
        type [Types::Analytics::Dimension, { null: false }], null: false

        def resolve_with_timings
          # TODO: Replace with ClickHouse
          sql = <<-SQL
            SELECT DISTINCT(ROUND(device_x, -1)) grouped_device_x, count(*) count
            FROM recordings
            INNER JOIN pages ON pages.recording_id = recordings.id
            WHERE
              recordings.device_x > 0 AND
              recordings.site_id = ? AND
              to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
              pages.url = ?
            GROUP BY grouped_device_x
          SQL

          variables = [
            object.site.id,
            object.range.from,
            object.range.to,
            object.page
          ]

          results = Sql.execute(sql, variables)

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
end
