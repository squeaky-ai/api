# typed: false
# frozen_string_literal: true

module Mutations
  module Admin
    class SiteBundlesCreate < AdminMutation
      null true

      graphql_name 'AdminSiteBundlesCreate'

      argument :site_id, ID, required: true
      argument :bundle_id, ID, required: true

      type Types::Sites::Bundle

      def resolve_with_timings(site_id:, bundle_id:)
        site = Site.find(site_id)
        site_bundle = SiteBundle.find(bundle_id)

        SiteBundlesSite.create!(site:, site_bundle:, primary: false)

        # The child site should inherit the primary plan
        site.plan.update(plan_id: site_bundle.primary_site.plan.plan_id)

        site_bundle.reload
      end
    end
  end
end
