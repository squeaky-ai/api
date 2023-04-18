# frozen_string_literal: true

module Resolvers
  module Admin
    class SitesCount < Resolvers::Base
      type Integer, null: false

      def resolve_with_timings
        Rails.cache.fetch('data_cache:AdminSitesCount', expires_in: 1.hour) do
          ::Site.all.count
        end
      end
    end
  end
end
