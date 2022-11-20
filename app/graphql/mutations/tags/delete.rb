# frozen_string_literal: true

module Mutations
  module Tags
    class Delete < SiteMutation
      null true

      graphql_name 'TagsDelete'

      argument :site_id, ID, required: true
      argument :tag_id, ID, required: true

      type Types::Tags::Tag

      def permitted_roles
        [Team::OWNER, Team::ADMIN, Team::MEMBER]
      end

      def resolve_with_timings(tag_id:)
        site.tags.find_by_id(tag_id)&.destroy

        nil
      end
    end
  end
end
