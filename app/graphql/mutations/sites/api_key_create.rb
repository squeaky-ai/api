# frozen_string_literal: true

module Mutations
  module Sites
    class ApiKeyCreate < SiteMutation
      null false

      graphql_name 'SitesApiKeyCreate'

      argument :site_id, ID, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve_with_timings
        site.update(api_key: SecureRandom.uuid)
        site
      end
    end
  end
end
