# frozen_string_literal: true

module DataCacheService
  module Recordings
    class Count < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL
            SELECT COUNT(*) total_recordings_count
            FROM recordings
            WHERE site_id = ? AND to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?
          SQL

          variables = [
            site.id,
            from_date,
            to_date
          ]

          Sql.execute(sql, variables).first['total_recordings_count']
        end
      end
    end
  end
end
