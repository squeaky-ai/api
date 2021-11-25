# frozen_string_literal: true

module Mutations
  module Sites
    class Update < SiteMutation
      null false

      argument :site_id, ID, required: true
      argument :name, String, required: false
      argument :url, String, required: false

      type Types::SiteType

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(name: nil, url: nil, **_rest)
        update = {}
        update[:name] = name if name

        if url
          update[:url] = uri(url)
          # Reset the verification if the url changes as
          # it could be incorrect
          update[:verified_at] = nil
        end

        @site.update(update)

        raise GraphQL::ExecutionError, @site.errors.full_messages.first unless @site.valid?

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
end
