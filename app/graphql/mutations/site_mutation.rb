# frozen_string_literal: true

module Mutations
  class SiteMutation < BaseMutation
    def ready?(args)
      @user = context[:current_user]
      raise Exceptions::Unauthorized unless @user

      @user.superuser? ? authorize_superuser(args) : authorize_normal_user(args)

      true
    end

    private

    # Regular users can only modify sites that exist and they
    # have permission to modifiy
    def authorize_normal_user(args)
      @site = @user.sites.find_by(id: args[:site_id])
      raise Exceptions::SiteNotFound unless @site

      team = @site.team.find_by(user_id: @user.id)
      raise Exceptions::SiteForbidden unless permitted_roles.include?(team.role)
    end

    # Superusers can see anything so long as it exists, and it's
    # up to the individual resolvers to let them modify things
    def authorize_superuser(args)
      @site = Site.find_by(id: args[:site_id])
      raise Exceptions::SiteNotFound unless @site
    end
  end
end
