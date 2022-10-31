# frozen_string_literal: true

module DataCacheService
  module Visitors
    class Count < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL
            SELECT
              COUNT(DISTINCT(visitor_id)) total_visitors_count
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
