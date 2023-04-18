# frozen_string_literal: true

module Mutations
  module Admin
    class SiteIngestUpdate < AdminMutation
      null true

      graphql_name 'AdminSiteIngestUpdate'

      argument :site_id, ID, required: true
      argument :enabled, Boolean, required: true

      type Types::Admin::Site

      def resolve_with_timings(site_id:, enabled:)
        site = Site.find(site_id)
        site.update(ingest_enabled: enabled)

        site
      end
    end
  end
end
