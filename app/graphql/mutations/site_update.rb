# frozen_string_literal: true

module Mutations
  # Update the sites name or url. If the url changes then
  # it will need to be reverified. Any ActiveRecord errors
  # are raised as GraphQL errors
  class SiteUpdate < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :name, String, required: false
    argument :url, String, required: false
    argument :dismiss_checklist, Boolean, required: false

    type Types::SiteType

    def permitted_roles
      [Team::OWNER, Team::ADMIN]
    end

    def resolve(name: nil, url: nil, dismiss_checklist: nil, **_rest)
      update = {}
      update[:name] = name if name
      update[:checklist_dismissed_at] = Time.now if dismiss_checklist

      if url
        update[:url] = uri(url)
        # Reset the verification if the url changes as
        # it could be incorrect
        update[:verified_at] = nil
      end

      @site.update(update)

      raise GraphQL::ExecutionError, @site.errors.full_messages.first unless @site.valid?

      # Best reset this just in case the url has changed!
      @site.create_authorizer!

      @site
    end

    private

    def uri(url)
      formatted_uri = Site.format_uri(url)
      # This is quite important! The last thing we want
      # is nil://nil being in there and being unique!
      raise Errors::SiteInvalidUri unless formatted_uri

      formatted_uri
    end
  end
end
