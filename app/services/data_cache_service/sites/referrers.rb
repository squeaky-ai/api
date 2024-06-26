# frozen_string_literal: true

module DataCacheService
  module Sites
    class Referrers < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL.squish
            SELECT
              DISTINCT(referrer) referrer
            FROM
              recordings
            WHERE
              site_id = :site_id AND
              referrer IS NOT NULL
          SQL

          variables = {
            site_id: site.id
          }

          Sql::ClickHouse.select_all(sql, variables).pluck('referrer')
        end
      end
    end
  end
end
