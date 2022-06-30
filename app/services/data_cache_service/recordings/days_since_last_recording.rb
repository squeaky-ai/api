# frozen_string_literal: true

module DataCacheService
  module Recordings
    class DaysSinceLastRecording < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL
            SELECT disconnected_at
            FROM recordings
            WHERE site_id = ?
            ORDER BY disconnected_at DESC
            LIMIT 1;
          SQL

          last_recorded_at = Sql.execute(sql, site_id).first

          return -1 unless last_recorded_at

          time_since_last_recording = Time.now.utc - Time.at(last_recorded_at['disconnected_at'].to_i / 1000)
          time_since_last_recording / 1.day
        end
      end
    end
  end
end
