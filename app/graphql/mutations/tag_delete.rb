# frozen_string_literal: true

module Mutations
  # Remove a tag from a recording
  class TagDelete < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :tag_id, ID, required: true

    type Types::SiteType

    def permitted_roles
      [Team::OWNER, Team::ADMIN, Team::MEMBER]
    end

    def resolve(tag_id:, **_rest)
      @site.tags.find_by_id(tag_id)&.destroy

      @site
    end
  end
end
