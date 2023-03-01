# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # Admin
    field :admin_blog_sign_image, mutation: Mutations::Admin::BlogSignImage
    field :admin_blog_delete_image, mutation: Mutations::Admin::BlogDeleteImage
    field :admin_blog_post_create, mutation: Mutations::Admin::BlogPostCreate
    field :admin_blog_post_delete, mutation: Mutations::Admin::BlogPostDelete
    field :admin_blog_post_update, mutation: Mutations::Admin::BlogPostUpdate
    field :admin_user_delete, mutation: Mutations::Admin::UserDelete
    field :admin_user_partner_create, mutation: Mutations::Admin::UserPartnerCreate
    field :admin_referral_delete, mutation: Mutations::Admin::ReferralDelete
    field :admin_site_plan_update, mutation: Mutations::Admin::SitePlanUpdate
    field :admin_site_associate_customer, mutation: Mutations::Admin::SiteAssociateCustomer
    field :admin_site_delete, mutation: Mutations::Admin::SiteDelete
    field :admin_site_ingest_update, mutation: Mutations::Admin::SiteIngestUpdate
    field :admin_site_team_delete, mutation: Mutations::Admin::SiteTeamDelete
    field :admin_site_team_update_role, mutation: Mutations::Admin::SiteTeamUpdateRole
    field :admin_site_bundles_create, mutation: Mutations::Admin::SiteBundlesCreate
    field :admin_partner_invoice_update, mutation: Mutations::Admin::PartnerInvoiceUpdate
    # Auth
    field :auth_confirm, mutation: Mutations::Auth::Confirm
    field :auth_reconfirm, mutation: Mutations::Auth::Reconfirm
    field :auth_password_reset, mutation: Mutations::Auth::PasswordReset
    field :auth_password_update, mutation: Mutations::Auth::PasswordUpdate
    field :auth_signup, mutation: Mutations::Auth::Signup
    # Users
    field :user_update, mutation: Mutations::Users::Update
    field :user_delete, mutation: Mutations::Users::Delete
    field :user_password, mutation: Mutations::Users::Password
    field :user_communication, mutation: Mutations::Users::Communication
    field :user_referral_create, mutation: Mutations::Users::ReferralCreate
    field :user_referral_delete, mutation: Mutations::Users::ReferralDelete
    field :user_invoice_create, mutation: Mutations::Users::InvoiceCreate
    field :user_invoice_delete, mutation: Mutations::Users::InvoiceDelete
    field :user_invoice_sign_image, mutation: Mutations::Users::InvoiceSignImage
    # Sites
    field :site_create, mutation: Mutations::Sites::Create
    field :site_update, mutation: Mutations::Sites::Update
    field :site_verify, mutation: Mutations::Sites::Verify
    field :site_delete, mutation: Mutations::Sites::Delete
    field :ip_blacklist_create, mutation: Mutations::Sites::IpBlacklistCreate
    field :ip_blacklist_delete, mutation: Mutations::Sites::IpBlacklistDelete
    field :domain_blacklist_create, mutation: Mutations::Sites::DomainBlacklistCreate
    field :domain_blacklist_delete, mutation: Mutations::Sites::DomainBlacklistDelete
    field :magic_erasure_update, mutation: Mutations::Sites::MagicErasureUpdate
    field :anonymise_preferences_update, mutation: Mutations::Sites::AnonymisePreferencesUpdate
    field :css_selector_blacklist_create, mutation: Mutations::Sites::CssSelectorBlacklistCreate
    field :css_selector_blacklist_delete, mutation: Mutations::Sites::CssSelectorBlacklistDelete
    field :superuser_access_update, mutation: Mutations::Sites::SuperuserAccessUpdate
    field :routes_update, mutation: Mutations::Sites::RoutesUpdate
    field :routes_delete, mutation: Mutations::Sites::RoutesDelete
    field :tracking_code_instructions, mutation: Mutations::Sites::TrackingCodeInstructions
    field :api_key_create, mutation: Mutations::Sites::ApiKeyCreate
    # Team
    field :team_invite, mutation: Mutations::Teams::Invite
    field :team_delete, mutation: Mutations::Teams::Delete
    field :team_leave, mutation: Mutations::Teams::Leave
    field :team_invite_cancel, mutation: Mutations::Teams::InviteCancel
    field :team_invite_resend, mutation: Mutations::Teams::InviteResend
    field :team_invite_accept, mutation: Mutations::Teams::InviteAccept
    field :team_update, mutation: Mutations::Teams::Update
    field :team_update_role, mutation: Mutations::Teams::UpdateRole
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
    # Consent
    field :consent_update, mutation: Mutations::Consent::Update
    # Visitors
    field :visitor_starred, mutation: Mutations::Visitors::Starred
    field :visitor_delete, mutation: Mutations::Visitors::Delete
    # Contact
    field :contact, mutation: Mutations::Contact::Contact
    field :book_demo, mutation: Mutations::Contact::BookDemo
    field :contact_partners, mutation: Mutations::Contact::Partners
    field :contact_startups, mutation: Mutations::Contact::Startups
    # Subscriptions
    field :subscriptions_create, mutation: Mutations::Subscriptions::Create
    field :subscriptions_update, mutation: Mutations::Subscriptions::Update
    field :subscriptions_portal, mutation: Mutations::Subscriptions::Portal
    # Public feedback
    field :nps_create, mutation: Mutations::Feedback::NpsCreate
    field :sentiment_create, mutation: Mutations::Feedback::SentimentCreate
    # Events
    field :event_group_create, mutation: Mutations::Events::GroupCreate
    field :event_group_delete, mutation: Mutations::Events::GroupDelete
    field :event_capture_create, mutation: Mutations::Events::CaptureCreate
    field :event_capture_update, mutation: Mutations::Events::CaptureUpdate
    field :event_capture_delete, mutation: Mutations::Events::CaptureDelete
    field :event_capture_delete_bulk, mutation: Mutations::Events::CaptureDeleteBulk
    field :event_add_to_group, mutation: Mutations::Events::AddToGroup
  end
end
