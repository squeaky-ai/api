# frozen_string_literal: true

module Resolvers
  module Admin
    class SitesProviders < Resolvers::Base
      type [Types::Admin::SitesProvider, { null: false }], null: false

      def resolve
        Rails.cache.fetch('data_cache:AdminSitesProviders', expires_in: 1.hour) do
          sql = <<-SQL.squish
            SELECT
              DISTINCT(COALESCE(provider, 'None')) provider_name,
              COUNT(*) count
            FROM
              sites
            GROUP BY
              sites.provider
          SQL

          Sql.execute(sql)
        end
      end
    end
  end
end
