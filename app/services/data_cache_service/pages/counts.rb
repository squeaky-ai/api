# frozen_string_literal: true

module DataCacheService
  module Pages
    class Counts < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL
            SELECT COUNT(pages.url) all_count, COUNT(DISTINCT(pages.url)) distinct_count
            FROM pages
            WHERE pages.site_id = ? AND to_timestamp(pages.entered_at / 1000)::date BETWEEN ? AND ?
          SQL

          variables = [site_id, from_date, to_date]

          Sql.execute(sql, variables).first
        end
      end
    end
  end
end
