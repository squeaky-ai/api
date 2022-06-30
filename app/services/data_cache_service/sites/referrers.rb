# frozen_string_literal: true

module DataCacheService
  module Sites
    class Referrers < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL
            SELECT DISTINCT(referrer) referrer
            FROM recordings
            WHERE site_id = ? AND referrer IS NOT NULL
          SQL

          Sql.execute(sql, site_id).map { |r| r['referrer'] }
        end
      end
    end
  end
end
