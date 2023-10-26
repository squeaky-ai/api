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

      def resolve_with_timings(visitor_id:)
        visitor = site.visitors.find_by(id: visitor_id)

        raise Exceptions::VisitorNotFound unless visitor

        visitor.destroy_all_recordings!
        visitor.destroy!

        nil
      end
    end
  end
end
