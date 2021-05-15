# frozen_string_literal: true

module Mutations
  # Admins can delete others (excluding the owner), if leaving
  # a site then the team_leave mutation should be used instead
  class TeamDelete < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :team_id, ID, required: true

    type Types::SiteType

    def resolve(team_id:, **_rest)
      team = @site.member(team_id)

      return @site if team.owner?
      return @site if team.user.id == @user.id

      team.delete
      TeamMailer.member_removed(team.user.email, @site).deliver_now

      @site.reload
    end
  end
end
