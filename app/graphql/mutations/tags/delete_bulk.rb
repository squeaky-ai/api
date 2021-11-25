# frozen_string_literal: true

module Mutations
  module Tags
    class DeleteBulk < SiteMutation
      null false

      graphql_name 'TagsDeleteBulk'

      argument :site_id, ID, required: true
      argument :tag_ids, [ID], required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN, Team::MEMBER]
      end

      def resolve(tag_ids:, **_rest)
        @site.tags.where(id: tag_ids)&.each { |t| t.destroy }

        @site
      end
    end
  end
end
