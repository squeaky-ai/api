# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
      class Devices < Resolvers::Base
        type [Types::Analytics::Device, { null: false }], null: false

        def resolve_with_timings
          sql = <<-SQL
            SELECT
              COUNT(device_type) FILTER(WHERE recordings.device_type = 'Computer') desktop_count,
              COUNT(device_type) FILTER(WHERE recordings.device_type = 'Mobile') mobile_count
            FROM
              recordings
            INNER JOIN
              page_events ON page_events.recording_id = recordings.recording_id
            WHERE
              recordings.site_id = :site_id AND
              toDate(recordings.disconnected_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date AND
              like(page_events.url, :url)
          SQL

          variables = {
            site_id: object.site.id,
            timezone: object.range.timezone,
            from_date: object.range.from,
            to_date: object.range.to,
            url: Paths.replace_route_with_wildcard(object.page)
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
end
