# frozen_string_literal: true

module DataCacheService
  module Sites
    class Languages < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL
            SELECT DISTINCT(locale) locale
            FROM recordings
            WHERE site_id = ? AND locale IS NOT NULL
          SQL

          Sql.execute(sql, site_id).map { |r| Locale.get_language(r['locale']) }
        end
      end
    end
  end
end
