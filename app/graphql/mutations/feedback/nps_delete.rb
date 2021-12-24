# frozen_string_literal: true

module Mutations
  module Feedback
    class NpsDelete < SiteMutation
      null true

      graphql_name 'NpsDelete'

      argument :site_id, ID, required: true
      argument :nps_id, ID, required: true

      type Types::Feedback::NpsResponseItem

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(nps_id:, **_rest)
        nps = @site.nps.find_by(id: nps_id)

        raise Errors::NpsNotFound unless nps

        nps.destroy

        nil
      end
    end
  end
end
