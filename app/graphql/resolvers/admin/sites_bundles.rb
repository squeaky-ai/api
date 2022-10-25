# frozen_string_literal: true

module Resolvers
  module Admin
    class SitesBundles < Resolvers::Base
      type [Types::Sites::Bundle, { null: false }], null: false

      def resolve_with_timings
        SiteBundle
          .includes(site_bundles_sites: :site)
          .all
      end
    end
  end
end
