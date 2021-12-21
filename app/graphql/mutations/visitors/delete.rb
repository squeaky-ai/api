# frozen_string_literal: true

module Mutations
  module Visitors
    class Delete < SiteMutation
      null false

      graphql_name 'VisitorsDelete'

      argument :site_id, ID, required: true
      argument :visitor_id, ID, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(visitor_id:, **_rest)
        visitor = @site.visitors.find_by(id: visitor_id)

        raise Errors::VisitorNotFound unless visitor

        visitor.destroy!

        @site
      end
    end
  end
end
