# frozen_string_literal: true

module DataCacheService
  module Recordings
    class DaysSinceLastRecording < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL.squish
            SELECT
              disconnected_at
            FROM
              recordings
            WHERE
              site_id = :site_id
            ORDER BY
              disconnected_at DESC
            LIMIT 1;
          SQL

          variables = {
            site_id: site.id
          }

          last_recorded_at = Sql::ClickHouse.select_value(sql, variables)

          return -1 unless last_recorded_at

          time_since_last_recording = Time.current.utc - Time.zone.at(last_recorded_at.to_i / 1000)
          time_since_last_recording / 1.day
        end
      end
    end
  end
end
