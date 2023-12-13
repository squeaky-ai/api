# frozen_string_literal: true

module Mutations
  module Visitors
    class Starred < SiteMutation
      null false

      graphql_name 'VisitorsStarred'

      argument :site_id, ID, required: true
      argument :visitor_id, ID, required: true
      argument :starred, Boolean, required: true

      type Types::Visitors::Visitor

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(visitor_id:, starred:)
        visitor = site.visitors.find_by(id: visitor_id)

        raise Exceptions::VisitorNotFound unless visitor

        visitor.update(starred:)

        visitor
      end
    end
  end
end
