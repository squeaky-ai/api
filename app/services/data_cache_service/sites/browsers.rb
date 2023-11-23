# frozen_string_literal: true

module DataCacheService
  module Sites
    class Browsers < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL.squish
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

          Sql::ClickHouse.select_all(sql, variables).pluck('browser')
        end
      end
    end
  end
end
