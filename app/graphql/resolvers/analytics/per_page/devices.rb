# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
      class Devices < Resolvers::Base
        type [Types::Analytics::Device, { null: false }], null: false

        def resolve_with_timings
          sql = <<-SQL
            SELECT
              COUNT(device_type) FILTER(WHERE device_type = 'Computer') desktop_count,
              COUNT(device_type) FILTER(WHERE device_type = 'Mobile') mobile_count
            FROM recordings
            INNER JOIN pages ON pages.recording_id = recordings.id
            WHERE
              recordings.site_id = ? AND
              to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
              pages.url = ?
          SQL

          variables = [
            object.site.id,
            object.range.from,
            object.range.to,
            object.page
          ]

          results = Sql.execute(sql, variables).first

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
end
