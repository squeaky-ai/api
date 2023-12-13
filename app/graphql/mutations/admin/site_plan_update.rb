# frozen_string_literal: true

module Mutations
  module Admin
    class SitePlanUpdate < AdminMutation
      null true

      graphql_name 'AdminSitePlanUpdate'

      argument :site_id, ID, required: true
      argument :max_monthly_recordings, Integer, required: false
      argument :support, [String, { null: false }], required: false
      argument :response_time_hours, Integer, required: false
      argument :data_storage_months, Integer, required: false
      argument :sso_enabled, Boolean, required: false
      argument :audit_trail_enabled, Boolean, required: false
      argument :private_instance_enabled, Boolean, required: false
      argument :notes, String, required: false
      argument :team_member_limit, Integer, required: false
      argument :features_enabled, [Types::Plans::Feature, { null: false }], required: false

      type Types::Admin::Site

      def resolve(site_id:, **args)
        site = Site.find(site_id)
        site.plan.update(args)

        site.plan.support_will_change! if args[:support]
        site.plan.features_enabled_will_change! if args[:features_enabled]

        site
      end
    end
  end
end
