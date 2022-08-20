# frozen_string_literal: true

module DataCacheService
  module Sites
    class UtmCampaigns < DataCacheService::Base
      def call
        cache do
          sql = <<-SQL
            SELECT DISTINCT(utm_campaign) utm_campaign
            FROM recordings
            WHERE site_id = ? AND utm_campaign IS NOT NULL
          SQL

          Sql.execute(sql, site.id).map { |r| r['utm_campaign'] }
        end
      end
    end
  end
end
