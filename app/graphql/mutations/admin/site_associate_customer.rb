# frozen_string_literal: true

module Mutations
  module Admin
    class SiteAssociateCustomer < BaseMutation
      null true

      graphql_name 'AdminSiteAssociateCustomer'

      argument :site_id, ID, required: true
      argument :customer_id, String, required: true

      type Types::Sites::Site

      def resolve(site_id:, customer_id:)
        raise Errors::Unauthorized unless context[:current_user]&.superuser?

        site = Site.find(site_id)

        return site if site.billing

        site.create_billing(customer_id:)

        site
      end
    end
  end
end
