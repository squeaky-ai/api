# frozen_string_literal: true

module Mutations
  # Admins can delete others (excluding the other), and anyone
  # can leave the site. The emails are different for users who
  # leave, vs being removed
  class TeamDelete < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :team_id, ID, required: true

    type Types::SiteType

    def resolve(team_id:, **_rest)
      member = @site.team.find { |t| t.id == team_id.to_i }

      # If the owner is trying to remove themself then they
      # need to transfer the ownership before hand. Otherwise
      # we do not allow anyone to remove the owner
      return @site if member.owner?

      member.delete
      send_emails(member)

      @site
    end

    private

    def send_emails(member)
      @site.members.each do |m|
        if m.id == member.id
          # If you've just removed yourself from the team then
          # there's no point in sending the email. However we
          # should definitely send it if some other team member
          # removed you
          TeamMailer.member_removed(m.user.email, @site, member.user).deliver_now unless m.user.id == @user.id
        else
          # This should get send to everyone in the team
          TeamMailer.member_left(m.user.email, @site, member.user).deliver_now
        end
      end
    end
  end
end
