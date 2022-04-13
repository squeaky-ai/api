# frozen_string_literal: true

module Resolvers
  module Sites
    class UtmCampaigns < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve
        utm_campaigns = Site
                        .find(object.id)
                        .recordings
                        .select(:utm_campaign)
                        .where('utm_campaign IS NOT NULL')
                        .distinct

        utm_campaigns.map(&:utm_campaign)
      end
    end
  end
end
