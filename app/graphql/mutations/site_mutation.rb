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

      @user.superuser? ? authorize_superuser(args) : authorize_normal_user(args)

      true
    end

    private

    # Regular users can only modify sites that exist and they
    # have permission to modifiy
    def authorize_normal_user(args)
      @site = @user.sites.find_by(id: args[:site_id].to_i)
      raise Errors::SiteNotFound unless @site

      team = @site.team.find_by(user_id: @user.id)
      raise Errors::SiteForbidden unless permitted_roles.include?(team.role)
    end

    # Superusers can see anything so long as it exists, and it's
    # up to the individual resolvers to let them modify things
    def authorize_superuser(args)
      @site = Site.find_by(id: args[:site_id].to_i)
      raise Errors::SiteNotFound unless @site
    end
  end
end
