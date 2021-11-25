# frozen_string_literal: true

module Mutations
  module Feedback
    class NpsDelete < SiteMutation
      null false

      graphql_name 'NpsDelete'

      argument :site_id, ID, required: true
      argument :nps_id, ID, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(nps_id:, **_rest)
        nps = @site.nps.find_by(id: nps_id)

        nps&.destroy

        @site
      end
    end
  end
end
