# frozen_string_literal: true

module Mutations
  module Feedback
    class Update < SiteMutation
      null false

      graphql_name 'FeedbackUpdate'

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

      type Types::Feedback::Feedback

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(**args)
        feedback = @site.feedback || ::Feedback.create(
          site_id: @site.id,
          nps_enabled: false,
          nps_accent_color: '#0074E0',
          nps_schedule: 'once',
          nps_phrase: @site.name,
          nps_follow_up_enabled: true,
          nps_contact_consent_enabled: false,
          nps_layout: 'full_width',
          sentiment_enabled: false,
          sentiment_accent_color: '#0074E0',
          sentiment_excluded_pages: [],
          sentiment_layout: 'right_middle'
        )

        feedback.assign_attributes(args.except(:site_id))
        feedback.save

        feedback
      end
    end
  end
end
