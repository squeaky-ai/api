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

      def resolve(nps_id:)
        nps = site.nps.find_by(id: nps_id)

        raise Exceptions::NpsNotFound unless nps

        nps.destroy

        nil
      end
    end
  end
end
