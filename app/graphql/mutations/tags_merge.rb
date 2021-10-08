# frozen_string_literal: true

module Mutations
  # Merge tagsz
  class TagsMerge < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :tag_ids, [ID], required: true
    argument :name, String, required: true

    type Types::SiteType

    def permitted_roles
      [Team::OWNER, Team::ADMIN, Team::MEMBER]
    end

    def resolve(tag_ids:, name:, **_rest)
      tags = @site.tags.where(id: tag_ids)

      return @site if tags.size.zero?

      tag = @site.tags.find_or_create_by(name: name)

      tags.each do |t|
        t.recordings.each do |r|
          r.tags.delete(t)
          r.tags << tag unless r.tags.include?(tag)
          r.save
        end

        t.destroy
      end

      @site
    end
  end
end
