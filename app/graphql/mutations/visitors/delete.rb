# frozen_string_literal: true

module Mutations
  module Visitors
    class Delete < SiteMutation
      null true

      graphql_name 'VisitorsDelete'

      argument :site_id, ID, required: true
      argument :visitor_id, ID, required: true

      type Types::Visitors::Visitor

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(visitor_id:, **_rest)
        visitor = @site.visitors.find_by(id: visitor_id)

        raise Exceptions::VisitorNotFound unless visitor

        visitor.destroy!

        nil
      end
    end
  end
end
