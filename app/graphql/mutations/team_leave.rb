# frozen_string_literal: true

module Mutations
  # Anyone but the owner can leave a site. If the
  # owner wants to leave, they must first transfer
  # ownership to someone else
  class TeamLeave < SiteMutation
    null true

    argument :site_id, ID, required: true

    type Types::SiteType

    def permitted_roles
      [Team::OWNER, Team::ADMIN]
    end

    def resolve(**_rest)
      team = @site.team.find { |t| t.user.id == @user.id }

      return @site if team.owner?

      TeamMailer.member_left(@site.owner.user.email, @site, team.user).deliver_now
      team.destroy

      nil
    end
  end
end
