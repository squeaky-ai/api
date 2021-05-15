# frozen_string_literal: true

require 'date'

module Mutations
  # Delete the site and clean up any data that's in Dynamo
  # and S3. This action can only be done by the owner
  class SiteDelete < SiteMutation
    null true

    argument :site_id, ID, required: true

    type Types::SiteType

    def resolve(**_args)
      raise Errors::Forbidden unless @user.owner_for?(@site)

      @site.delete_authorizer!
      @site.destroy

      nil
    end
  end
end
