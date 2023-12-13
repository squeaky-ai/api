# frozen_string_literal: true

module Resolvers
  module Sites
    class Plans < Resolvers::Base
      type [Types::Plans::DecoratedPlan, { null: false }], null: false

      argument :site_id, ID, required: false

      def resolve(site_id: nil)
        ::PlansDecorator.new(plans: ::Plans.to_a, site: fetch_site(site_id)).decrorate
      end

      def fetch_site(site_id)
        return unless site_id
        return unless context[:current_user]

        SiteService.find_by_id(context[:current_user], site_id)
      end
    end
  end
end
