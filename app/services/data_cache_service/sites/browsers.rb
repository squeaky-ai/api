# typed: false
# frozen_string_literal: true

module DataCacheService
  module Sites
    class Browsers < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL
            SELECT
              DISTINCT(browser) browser
            FROM
              recordings
            WHERE
              site_id = :site_id
          SQL

          variables = {
            site_id: site.id
          }

          Sql::ClickHouse.select_all(sql, variables).map { |r| r['browser'] }
        end
      end
    end
  end
end
