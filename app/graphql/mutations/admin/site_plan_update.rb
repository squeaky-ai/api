# frozen_string_literal: true

module Mutations
  module Admin
    class SitePlanUpdate < BaseMutation
      null true

      graphql_name 'AdminSitePlanUpdate'

      argument :site_id, ID, required: true
      argument :max_monthly_recordings, Integer, required: false
      argument :support, [String, { null: true }], required: false
      argument :response_time_hours, Integer, required: false
      argument :data_storage_months, Integer, required: false
      argument :sso_enabled, Boolean, required: false
      argument :audit_trail_enabled, Boolean, required: false
      argument :private_instance_enabled, Boolean, required: false
      argument :notes, String, required: false

      type Types::Sites::Site

      def resolve(site_id:, **rest)
        raise Errors::Unauthorized unless context[:current_user]&.superuser?

        site = Site.find(site_id)
        site.plan.update(rest)

        site
      end
    end
  end
end
