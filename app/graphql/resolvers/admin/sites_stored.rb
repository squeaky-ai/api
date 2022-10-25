# frozen_string_literal: true

module Resolvers
  module Admin
    class SitesStored < Resolvers::Base
      type [Types::Admin::SitesStored, { null: false }], null: false

      def resolve_with_timings
        Rails.cache.fetch('data_cache:AdminSitesStored', expires_in: 1.hour) do
          sql = <<-SQL
            SELECT
              (COUNT(*)) as all_count,
              (COUNT(*) FILTER(WHERE verified_at IS NOT NULL)) as verified_count,
              (COUNT(*) FILTER(WHERE verified_at IS NULL)) as unverified_count,
              created_at::date date
            FROM sites
            GROUP BY date
            ORDER BY date ASC;
          SQL

          Sql.execute(sql)
        end
      end
    end
  end
end
