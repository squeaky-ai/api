# frozen_string_literal: true

module Mutations
  module Tags
    class Delete < SiteMutation
      null false

      graphql_name 'TagsDeleteInput'

      argument :site_id, ID, required: true
      argument :tag_id, ID, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN, Team::MEMBER]
      end

      def resolve(tag_id:, **_rest)
        @site.tags.find_by_id(tag_id)&.destroy

        @site
      end
    end
  end
end
