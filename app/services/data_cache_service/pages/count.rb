# frozen_string_literal: true

module DataCacheService
  module Pages
    class Count < DataCacheService::Base
      # TODO: Timezone
      def call
        cache do
          sql = <<-SQL
            SELECT
              COUNT(*) pages_count
            FROM
              page_events
            WHERE
              site_id = ? AND
              toDate(exited_at / 1000)::date BETWEEN ? AND ?
          SQL

          variables = [site.id, from_date, to_date]

          Sql::ClickHouse.select_value(sql, variables)
        end
      end
    end
  end
end
