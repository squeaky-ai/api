# frozen_string_literal: true

module Mutations
  # Update an existing tags name
  class TagUpdate < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :tag_id, ID, required: true
    argument :name, String, required: true

    type Types::SiteType

    def permitted_roles
      [Team::OWNER, Team::ADMIN, Team::MEMBER]
    end

    def resolve(tag_id:, name:, **_rest)
      @site.tags.find_by_id(tag_id)&.update(name: name)

      @site
    end
  end
end
