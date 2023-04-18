# frozen_string_literal: true

module Mutations
  module Events
    class GroupDelete < SiteMutation
      null true

      graphql_name 'EventGroupDelete'

      argument :site_id, ID, required: true
      argument :group_id, ID, required: true

      type Types::Events::Group

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve_with_timings(group_id:)
        group = site.event_groups.find_by(id: group_id)

        group&.destroy

        nil
      end
    end
  end
end
