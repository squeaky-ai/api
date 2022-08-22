# frozen_string_literal: true

module Resolvers
  module Sites
    class SiteByUuid < Resolvers::Base
      type Types::Sites::Site, null: true

      argument :site_id, ID, required: true

      def resolve_with_timings(site_id:)
        SiteService.find_by_uuid(context[:current_user], site_id)
      end
    end
  end
end
