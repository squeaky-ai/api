# frozen_string_literal: true

module DataCacheService
  module Sites
    class Browsers < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL
            SELECT DISTINCT(browser) browser
            FROM recordings
            WHERE site_id = ?
          SQL

          Sql.execute(sql, site_id).map { |r| r['browser'] }
        end
      end
    end
  end
end
