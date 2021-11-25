# frozen_string_literal: true

module Mutations
  class TagsDelete < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :tag_ids, [ID], required: true

    type Types::SiteType

    def permitted_roles
      [Team::OWNER, Team::ADMIN, Team::MEMBER]
    end

    def resolve(tag_ids:, **_rest)
      @site.tags.where(id: tag_ids)&.each { |t| t.destroy }

      @site
    end
  end
end
