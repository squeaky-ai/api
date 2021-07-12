# frozen_string_literal: true

module Mutations
  # An asbstraction of authentication and authorization
  # around sites. It requires the user and site to exist,
  # as well as the user being an admin/owner (as regular
  # users can't modify anything).
  class SiteMutation < BaseMutation
    def ready?(args)
      @user = context[:current_user]
      raise Errors::Unauthorized unless @user

      @site = @user.sites.find_by(id: args[:site_id].to_i)
      raise Errors::SiteNotFound unless @site

      team = @site.team.find_by(user_id: @user.id)
      raise Errors::SiteForbidden unless permitted_roles.include?(team.role)

      true
    end
  end
end
