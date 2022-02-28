# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # Auth
    field :auth_confirm, mutation: Mutations::Auth::Confirm
    field :auth_reconfirm, mutation: Mutations::Auth::Reconfirm
    field :auth_reset_password, mutation: Mutations::Auth::ResetPassword
    # Users
    field :user_update, mutation: Mutations::Users::Update
    field :user_delete, mutation: Mutations::Users::Delete
    field :user_password, mutation: Mutations::Users::Password
    field :user_communication, mutation: Mutations::Users::Communication
    # Sites
    field :site_create, mutation: Mutations::Sites::Create
    field :site_update, mutation: Mutations::Sites::Update
    field :site_verify, mutation: Mutations::Sites::Verify
    field :site_delete, mutation: Mutations::Sites::Delete
    field :ip_blacklist_create, mutation: Mutations::Sites::IpBlacklistCreate
    field :ip_blacklist_delete, mutation: Mutations::Sites::IpBlacklistDelete
    field :domain_blacklist_create, mutation: Mutations::Sites::DomainBlacklistCreate
    field :domain_blacklist_delete, mutation: Mutations::Sites::DomainBlacklistDelete
    # Team
    field :team_invite, mutation: Mutations::Teams::Invite
    field :team_delete, mutation: Mutations::Teams::Delete
    field :team_leave, mutation: Mutations::Teams::Leave
    field :team_invite_cancel, mutation: Mutations::Teams::InviteCancel
    field :team_invite_resend, mutation: Mutations::Teams::InviteResend
    field :team_invite_accept, mutation: Mutations::Teams::InviteAccept
    field :team_update, mutation: Mutations::Teams::Update
    field :team_transfer, mutation: Mutations::Teams::Transfer
    # Recordings
    field :tag_create, mutation: Mutations::Tags::Create
    field :tag_delete, mutation: Mutations::Tags::Delete
    field :tag_update, mutation: Mutations::Tags::Update
    field :tag_remove, mutation: Mutations::Tags::Remove
    field :tags_delete, mutation: Mutations::Tags::DeleteBulk
    field :note_create, mutation: Mutations::Notes::Create
    field :note_update, mutation: Mutations::Notes::Update
    field :note_delete, mutation: Mutations::Notes::Delete
    field :recording_delete, mutation: Mutations::Recordings::Delete
    field :recording_viewed, mutation: Mutations::Recordings::Viewed
    field :recording_bookmarked, mutation: Mutations::Recordings::Bookmarked
    field :recordings_delete, mutation: Mutations::Recordings::DeleteBulk
    field :recordings_viewed, mutation: Mutations::Recordings::ViewedBulk
    # Feedback
    field :feedback_update, mutation: Mutations::Feedback::Update
    field :nps_delete, mutation: Mutations::Feedback::NpsDelete
    field :sentiment_delete, mutation: Mutations::Feedback::SentimentDelete
    # Visitors
    field :visitor_starred, mutation: Mutations::Visitors::Starred
    field :visitor_delete, mutation: Mutations::Visitors::Delete
    # Contact
    field :contact, mutation: Mutations::Contact::Contact
    field :book_demo, mutation: Mutations::Contact::BookDemo
    # Subscriptions
    field :subscriptions_create, mutation: Mutations::Subscriptions::Create
    field :subscriptions_update, mutation: Mutations::Subscriptions::Update
    field :subscriptions_portal, mutation: Mutations::Subscriptions::Portal

    # Public feedback
    field :nps_create, mutation: Mutations::Feedback::NpsCreate
    field :sentiment_create, mutation: Mutations::Feedback::SentimentCreate
  end
end
