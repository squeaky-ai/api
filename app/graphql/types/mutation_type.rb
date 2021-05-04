# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # Auth
    field :auth_request,
          mutation: Mutations::AuthRequest,
          description: 'Requst an auth token to be sent to the provided email'
    field :auth_verify,
          mutation: Mutations::AuthVerify,
          description: 'Verify that the auth token matches the one stored'

    # Users
    field :user_update,
          mutation: Mutations::UserUpdate,
          description: 'Update a user\'s details'
    field :user_delete,
          mutation: Mutations::UserDelete,
          description: 'Delet a user'

    # Sites
    field :site_create,
          mutation: Mutations::SiteCreate,
          description: 'Create a new, unverified site'
    field :site_update,
          mutation: Mutations::SiteUpdate,
          description: 'Update a site\'s details. If the url is changed, the verification will be reset'
    field :site_verify,
          mutation: Mutations::SiteVerify,
          description: 'Verify that the site has the script installed correctly'

    # Team
    field :team_invite,
          mutation: Mutations::TeamInvite,
          description: 'Invite a team member by sending them an email'
    field :team_invite_cancel,
          mutation: Mutations::TeamInviteCancel,
          description: 'Cancel a team members invite if their status is pending'
    field :team_invite_resend,
          mutation: Mutations::TeamInviteResend,
          description: 'Resend an invite to a team member if their status is pending'
    field :team_update,
          mutation: Mutations::TeamUpdate,
          description: 'Update a team member'
  end
end
