# frozen_string_literal: true

module Resolvers
  module Sites
    class UtmCampaigns < Resolvers::Base
      type [String, { null: false }], null: false

      def resolve
        DataCacheService::Sites::UtmCampaigns.new(site: object).call
      end
    end
  end
end
