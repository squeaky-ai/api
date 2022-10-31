# frozen_string_literal: true

module DataCacheService
  module Sites
    class UtmMediums < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL
            SELECT
              DISTINCT(utm_medium) utm_medium
            FROM
              recordings
            WHERE
              site_id = ? AND
              utm_medium IS NOT NULL
          SQL

          Sql::ClickHouse.select_all(sql, site.id).map { |r| r['utm_medium'] }
        end
      end
    end
  end
end
