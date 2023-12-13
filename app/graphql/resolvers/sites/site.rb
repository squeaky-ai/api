# frozen_string_literal: true

module Resolvers
  module Sites
    class Site < Resolvers::Base
      type Types::Sites::Site, null: true

      argument :site_id, ID, required: true

      def resolve(site_id:)
        SiteService.find_by_id(context[:current_user], site_id)
      end
    end
  end
end
