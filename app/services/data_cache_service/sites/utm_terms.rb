# frozen_string_literal: true

module DataCacheService
  module Sites
    class UtmTerms < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL
            SELECT
              DISTINCT(utm_term) utm_term
            FROM
              recordings
            WHERE
              site_id = ? AND
              utm_term IS NOT NULL
          SQL

          Sql::ClickHouse.select_all(sql, site.id).map { |r| r['utm_term'] }
        end
      end
    end
  end
end
