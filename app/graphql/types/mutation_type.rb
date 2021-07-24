# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # Users
    field :user_update,
          mutation: Mutations::UserUpdate,
          description: 'Update a user\'s details'
    field :user_delete,
          mutation: Mutations::UserDelete,
          description: 'Delete a user'
    field :user_password,
          mutation: Mutations::UserPassword,
          description: 'Update the users password'

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
    field :site_delete,
          mutation: Mutations::SiteDelete,
          description: 'Delete the site, team and any recording data'

    # Team
    field :team_invite,
          mutation: Mutations::TeamInvite,
          description: 'Invite a team member by sending them an email'
    field :team_delete,
          mutation: Mutations::TeamDelete,
          description: 'Delete a team member'
    field :team_leave,
          mutation: Mutations::TeamLeave,
          description: 'Leave a team'
    field :team_invite_cancel,
          mutation: Mutations::TeamInviteCancel,
          description: 'Cancel a team members invite if their status is pending'
    field :team_invite_resend,
          mutation: Mutations::TeamInviteResend,
          description: 'Resend an invite to a team member if their status is pending'
    field :team_invite_accept,
          mutation: Mutations::TeamInviteAccept,
          description: 'Use the invite token to accept a team members invite'
    field :team_update,
          mutation: Mutations::TeamUpdate,
          description: 'Update a team member'
    field :team_transfer,
          mutation: Mutations::TeamTransfer,
          description: 'Transfer ownership of the site to another team member'

    # Recordings
    field :tag_create,
          mutation: Mutations::TagCreate,
          description: 'Create a new tag against a recording'
    field :tag_update,
          mutation: Mutations::TagUpdate,
          description: 'Update the name of an existing tag'
    field :tag_delete,
          mutation: Mutations::TagDelete,
          description: 'Delete the tag'
    field :note_create,
          mutation: Mutations::NoteCreate,
          description: 'Create a new note against a recording'
    field :note_update,
          mutation: Mutations::NoteUpdate,
          description: 'Update an existing note'
    field :note_delete,
          mutation: Mutations::NoteDelete,
          description: 'Delete a note'
    field :recording_delete,
          mutation: Mutations::RecordingDelete,
          description: 'Delete a recording'
    field :recording_viewed,
          mutation: Mutations::RecordingViewed,
          description: 'Mark a recording as viewed'
    field :recording_bookmarked,
          mutation: Mutations::RecordingBookmarked,
          description: 'Set a recordings bookmarked status'
  end
end
