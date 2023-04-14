# typed: false
# frozen_string_literal: true

module Resolvers
  module Admin
    class Site < Resolvers::Base
      type Types::Admin::Site, null: true

      argument :site_id, ID, required: true

      def resolve_with_timings(site_id:)
        ::Site.find_by(id: site_id)
      end
    end
  end
end
