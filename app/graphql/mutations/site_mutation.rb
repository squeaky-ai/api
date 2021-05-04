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

      @site = @user.sites.find { |s| s.id == args[:site_id].to_i }

      raise Errors::SiteNotFound unless @site
      raise Errors::SiteForbidden unless @user.admin_for?(@site)

      true
    end
  end
end
