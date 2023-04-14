# typed: false
# frozen_string_literal: true

module Resolvers
  module Sites
    class SiteSessionSettings < Resolvers::Base
      type Types::Sites::SessionSettings, null: true

      argument :site_id, String, required: true

      def resolve_with_timings(site_id:)
        site = ::Site.new(uuid: site_id)
        DataCacheService::Sites::Settings.new(site:, user: context[:current_user]).call
      end
    end
  end
end
