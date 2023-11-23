# frozen_string_literal: true

module DataCacheService
  module Visitors
    class Count < DataCacheService::Base
      # TODO: Timezone
      def call
        cache do
          sql = <<-SQL.squish
            SELECT
              COUNT(DISTINCT(visitor_id)) total_visitors_count
            FROM
              recordings
            WHERE
              site_id = :site_id AND
              toDate(disconnected_at / 1000)::date BETWEEN :from_date AND :to_date
          SQL

          variables = {
            site_id: site.id,
            from_date:,
            to_date:
          }

          Sql::ClickHouse.select_value(sql, variables)
        end
      end
    end
  end
end
