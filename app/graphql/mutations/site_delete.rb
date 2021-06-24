# frozen_string_literal: true

module Mutations
  # Delete the site and clean up any data that we have
  # stored. This action can only be done by the owner
  class SiteDelete < SiteMutation
    null true

    argument :site_id, ID, required: true

    type Types::SiteType

    def resolve(**_args)
      raise Errors::Forbidden unless @user.owner_for?(@site)

      @site.delete_authorizer!
      # Send an email to everyone in the team besides the owner
      @site.team.each { |t| SiteMailer.destroyed(t.user.email, @site).deliver_now unless t.owner? }
      @site.destroy

      nil
    end
  end
end
