# frozen_string_literal: true

module DataCacheService
  module Sites
    class UtmCampaigns < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL.squish
            SELECT
              DISTINCT(utm_campaign) utm_campaign
            FROM
              recordings
            WHERE
              site_id = :site_id AND
              utm_campaign IS NOT NULL
          SQL

          variables = {
            site_id: site.id
          }

          Sql::ClickHouse.select_all(sql, variables).pluck('utm_campaign')
        end
      end
    end
  end
end
