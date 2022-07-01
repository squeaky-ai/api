# frozen_string_literal: true

module DataCacheService
  module Pages
    class Count < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL
            SELECT COUNT(pages.id) pages_count
            FROM pages
            WHERE pages.site_id = ? AND to_timestamp(pages.exited_at / 1000)::date BETWEEN ? AND ?
          SQL

          variables = [site_id, from_date, to_date]

          Sql.execute(sql, variables).first['pages_count']
        end
      end
    end
  end
end
