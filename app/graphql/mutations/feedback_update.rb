# frozen_string_literal: true

module Mutations
  # Update the feedback and create the record if one
  # does not exist
  class FeedbackUpdate < SiteMutation
    null false

    argument :site_id, ID, required: true
    argument :nps_enabled, Boolean, required: false
    argument :nps_accent_color, String, required: false
    argument :nps_schedule, String, required: false
    argument :nps_phrase, String, required: false
    argument :nps_follow_up_enabled, Boolean, required: false
    argument :nps_contact_consent_enabled, Boolean, required: false
    argument :nps_layout, String, required: false
    argument :sentiment_enabled, Boolean, required: false
    argument :sentiment_accent_color, String, required: false
    argument :sentiment_excluded_pages, [String], required: false
    argument :sentiment_layout, String, required: false

    type Types::SiteType

    def permitted_roles
      [Team::OWNER, Team::ADMIN]
    end

    def resolve(**args)
      feedback = @site.feedback || Feedback.create(site_id: @site.id)

      feedback.assign_attributes(args.except(:site_id))
      feedback.save

      @site.reload
    end
  end
end
