# frozen_string_literal: true

require 'date'

module Resolvers
  module Recordings
    class DaysSinceLastRecording < Resolvers::Base
      type Integer, null: false

      def resolve_with_timings
        # TODO: Cache this for 5/10 minutes as it gets hit all the time
        sql = <<-SQL
          SELECT disconnected_at
          FROM recordings
          WHERE site_id = ?
          ORDER BY disconnected_at DESC
          LIMIT 1;
        SQL

        last_recorded_at = Sql.execute(sql, object.id).first

        return -1 unless last_recorded_at

        time_since_last_recording = Time.now.utc - Time.at(last_recorded_at['disconnected_at'].to_i / 1000)
        time_since_last_recording / 1.day
      end
    end
  end
end
