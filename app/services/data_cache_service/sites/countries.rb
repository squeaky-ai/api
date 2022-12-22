# frozen_string_literal: true

module DataCacheService
  module Sites
    class Countries < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL
            SELECT
              country_code,
              COUNT(country_code) count
            FROM
              recordings
            WHERE
              site_id = ? AND
              country_code IS NOT NULL
            GROUP BY
              country_code
          SQL

          Sql::ClickHouse.select_all(sql, site.id).map do |r|
            {
              count: r['count'],
              code: r['country_code'],
              name: ::Countries.get_country(r['country_code'])
            }
          end
        end
      end
    end
  end
end
