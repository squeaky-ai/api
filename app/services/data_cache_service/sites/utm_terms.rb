# frozen_string_literal: true

module DataCacheService
  module Sites
    class UtmTerms < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL.squish
            SELECT
              DISTINCT(utm_term) utm_term
            FROM
              recordings
            WHERE
              site_id = :site_id AND
              utm_term IS NOT NULL
          SQL

          variables = {
            site_id: site.id
          }

          Sql::ClickHouse.select_all(sql, variables).pluck('utm_term')
        end
      end
    end
  end
end
