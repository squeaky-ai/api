# frozen_string_literal: true

module Mutations
  # Set the visitor starred status
  class VisitorStarred < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :visitor_id, ID, required: true
    argument :starred, Boolean, required: true

    type Types::SiteType

    def permitted_roles
      [Team::OWNER, Team::ADMIN]
    end

    def resolve(visitor_id:, starred:, **_rest)
      visitor = @site.visitors.find_by(id: visitor_id)

      raise Errors::VisitorNotFound unless visitor

      visitor.update(starred: starred)

      @site
    end
  end
end
