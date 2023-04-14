# typed: false
# frozen_string_literal: true

module Mutations
  module Tags
    class Update < SiteMutation
      null true

      graphql_name 'TagsUpdate'

      argument :site_id, ID, required: true
      argument :tag_id, ID, required: true
      argument :name, String, required: true

      type Types::Tags::Tag

      def permitted_roles
        [Team::OWNER, Team::ADMIN, Team::MEMBER]
      end

      def resolve_with_timings(tag_id:, name:)
        tag = site.tags.find_by_id(tag_id)

        tag&.update(name:)

        tag
      end
    end
  end
end
