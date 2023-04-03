# frozen_string_literal: true

module DataCacheService
  module Recordings
    class Count < DataCacheService::Base
      # TODO: Timezone
      def call
        cache do
          sql = <<-SQL
            SELECT
              COUNT(*) total_recordings_count
            FROM
              recordings
            WHERE
              site_id = ? AND
              toDate(disconnected_at / 1000)::date BETWEEN ? AND ?
          SQL

          variables = [
            site.id,
            from_date,
            to_date
          ]

          Sql::ClickHouse.select_value(sql, variables)
        end
      end
    end
  end
end
