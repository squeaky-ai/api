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
    field :ip_blacklist_create,
          mutation: Mutations::SiteIpBlacklistCreate,
          description: 'Create a new entry in the ip blacklist'
    field :ip_blacklist_delete,
          mutation: Mutations::SiteIpBlacklistDelete,
          description: 'Delete an entry from the ip blacklist'
    field :domain_blacklist_create,
          mutation: Mutations::SiteDomainBlacklistCreate,
          description: 'Create a new entry in the domain blacklist'
    field :domain_blacklist_delete,
          mutation: Mutations::SiteDomainBlacklistDelete,
          description: 'Delete an entry from the domain blacklist'
    field :feedback_update,
          mutation: Mutations::FeedbackUpdate,
          description: 'Update/upsert the site feedback settings'

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
    field :tag_delete,
          mutation: Mutations::TagDelete,
          description: 'Delete a tag'
    field :tags_delete,
          mutation: Mutations::TagsDelete,
          description: 'Delete multiple tags'
    field :tag_update,
          mutation: Mutations::TagUpdate,
          description: 'Update the name of an existing tag'
    field :tag_remove,
          mutation: Mutations::TagRemove,
          description: 'Remove a tag from a recording'
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
    field :recordings_delete,
          mutation: Mutations::RecordingsDelete,
          description: 'Bulk delete recordings'
    field :recordings_viewed,
          mutation: Mutations::RecordingsViewed,
          description: 'Bulk view/unview recordings'

    # Feedback
    field :feedback_create,
          mutation: Mutations::FeedbackCreate,
          description: 'Provide some feedback'

    # Visitors
    field :visitor_starred,
          mutation: Mutations::VisitorStarred,
          description: 'Set the starred state for a visitor'
  end
end
