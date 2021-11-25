# frozen_string_literal: true

module Mutations
  module Tags
    class Update < SiteMutation
      null false

      graphql_name 'TagsUpdateInput'

      argument :site_id, ID, required: true
      argument :tag_id, ID, required: true
      argument :name, String, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN, Team::MEMBER]
      end

      def resolve(tag_id:, name:, **_rest)
        @site.tags.find_by_id(tag_id)&.update(name: name)

        @site
      end
    end
  end
end
