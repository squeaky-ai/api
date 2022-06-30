# frozen_string_literal: true

module Resolvers
  module Sites
    class UtmCampaigns < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve_with_timings
        sql = <<-SQL
          SELECT DISTINCT(utm_campaign) utm_campaign
          FROM recordings
          WHERE site_id = ? AND utm_campaign IS NOT NULL
        SQL

        Sql.execute(sql, object.id).map { |r| r['utm_campaign'] }
      end
    end
  end
end
