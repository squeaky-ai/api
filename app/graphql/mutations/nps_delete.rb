# frozen_string_literal: true

module Mutations
  # Delete an nps response
  class NpsDelete < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :nps_id, ID, required: true

    type Types::SiteType

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
