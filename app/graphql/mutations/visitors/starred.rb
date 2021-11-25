# frozen_string_literal: true

module Mutations
  module Visitors
    class Starred < SiteMutation
      null false

      argument :site_id, ID, required: true
      argument :visitor_id, ID, required: true
      argument :starred, Boolean, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(visitor_id:, starred:, **_rest)
        visitor = @site.visitors.find_by(id: visitor_id)

        raise Errors::VisitorNotFound unless visitor

        visitor.update(starred: starred)

        @site
      end
    end
  end
end
