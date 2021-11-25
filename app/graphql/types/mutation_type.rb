# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # Users
    field :user_update, mutation: Mutations::UserUpdate
    field :user_delete, mutation: Mutations::UserDelete
    field :user_password, mutation: Mutations::UserPassword
    # Sites
    field :site_create, mutation: Mutations::SiteCreate
    field :site_update, mutation: Mutations::SiteUpdate
    field :site_verify, mutation: Mutations::SiteVerify
    field :site_delete, mutation: Mutations::SiteDelete
    field :ip_blacklist_create, mutation: Mutations::SiteIpBlacklistCreate
    field :ip_blacklist_delete, mutation: Mutations::SiteIpBlacklistDelete
    field :domain_blacklist_create, mutation: Mutations::SiteDomainBlacklistCreate
    field :domain_blacklist_delete, mutation: Mutations::SiteDomainBlacklistDelete
    field :feedback_update, mutation: Mutations::FeedbackUpdate
    # Team
    field :team_invite, mutation: Mutations::TeamInvite
    field :team_delete, mutation: Mutations::TeamDelete
    field :team_leave, mutation: Mutations::TeamLeave
    field :team_invite_cancel, mutation: Mutations::TeamInviteCancel
    field :team_invite_resend, mutation: Mutations::TeamInviteResend
    field :team_invite_accept, mutation: Mutations::TeamInviteAccept
    field :team_update, mutation: Mutations::TeamUpdate
    field :team_transfer, mutation: Mutations::TeamTransfer
    # Recordings
    field :tag_create, mutation: Mutations::TagCreate
    field :tag_delete, mutation: Mutations::TagDelete
    field :tags_delete, mutation: Mutations::TagsDelete
    field :tag_update, mutation: Mutations::TagUpdate
    field :tag_remove, mutation: Mutations::TagRemove
    field :note_create, mutation: Mutations::NoteCreate
    field :note_update, mutation: Mutations::NoteUpdate
    field :note_delete, mutation: Mutations::NoteDelete
    field :recording_delete, mutation: Mutations::RecordingDelete
    field :recording_viewed, mutation: Mutations::RecordingViewed
    field :recording_bookmarked, mutation: Mutations::RecordingBookmarked
    field :recordings_delete, mutation: Mutations::RecordingsDelete
    field :recordings_viewed, mutation: Mutations::RecordingsViewed
    # Feedback
    field :feedback_create, mutation: Mutations::FeedbackCreate
    field :nps_delete, mutation: Mutations::NpsDelete
    field :sentiment_delete, mutation: Mutations::SentimentDelete
    # Visitors
    field :visitor_starred, mutation: Mutations::VisitorStarred
  end
end
