# frozen_string_literal: true

module DataCacheService
  module Sites
    class UtmSources < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL.squish
            SELECT
              DISTINCT(utm_source) utm_source
            FROM
              recordings
            WHERE
              site_id = :site_id AND
              utm_source IS NOT NULL
          SQL

          variables = {
            site_id: site.id
          }

          Sql::ClickHouse.select_all(sql, variables).pluck('utm_source')
        end
      end
    end
  end
end
