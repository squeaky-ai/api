# frozen_string_literal: true

module Mutations
  # Validate a jwt invite token and accept the users
  # invite. This action can be done without auth as there
  # is a good chance that the user does not have a squeaky
  # account yet
  class TeamInviteAccept < Mutations::BaseMutation
    null false

    argument :token, String, required: true

    type Types::SiteType

    def resolve(token:)
      payload = extract_payload(token)

      site = Site.find(payload['site_id'].to_i)
      member = site.member(payload['team_id'])

      raise Errors::TeamInviteExpired unless member

      member.update(status: Team::ACCEPTED)

      # TODO: Is there a better thing to return here? The
      # user may not have ever logged in
      site
    end

    private

    def extract_payload(token)
      JsonWebToken.decode(token)
    rescue JWT::ExpiredSignature
      raise Errors::TeamInviteExpired
    rescue JWT::DecodeError => e
      Rails.logger.warn e
      raise Errors::TeamInviteInvalid
    end
  end
end
