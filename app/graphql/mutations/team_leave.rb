# frozen_string_literal: true

module Mutations
  # Anyone but the owner can leave a site. If the
  # owner wants to leave, they must first transfer
  # ownership to someone else
  class TeamLeave < SiteMutation
    null true

    argument :site_id, ID, required: true

    type Types::SiteType

    def resolve(**_rest)
      team = @site.team.find { |t| t.user.id == @user.id }

      return @site if team.owner?

      team.delete
      send_emails(team)

      nil
    end

    private

    def send_emails(team)
      @site.team.each do |m|
        # Don't send this to yourself
        next if m.id == team.id

        TeamMailer.member_left(m.user.email, @site, team.user).deliver_now
      end
    end
  end
end
