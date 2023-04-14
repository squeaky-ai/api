# typed: false
# frozen_string_literal: true

module DataCacheService
  module Sites
    class UtmContents < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL
            SELECT
              DISTINCT(utm_content) utm_content
            FROM
              recordings
            WHERE
              site_id = :site_id AND
              utm_content IS NOT NULL
          SQL

          variables = {
            site_id: site.id
          }

          Sql::ClickHouse.select_all(sql, variables).map { |r| r['utm_content'] }
        end
      end
    end
  end
end
