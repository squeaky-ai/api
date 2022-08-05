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
      argument :nps_excluded_pages, [String], required: false
      argument :nps_languages, [String], required: false
      argument :nps_languages_default, String, required: false
      argument :nps_hide_logo, Boolean, required: false
      argument :sentiment_enabled, Boolean, required: false
      argument :sentiment_accent_color, String, required: false
      argument :sentiment_excluded_pages, [String], required: false
      argument :sentiment_layout, String, required: false
      argument :sentiment_devices, [String], required: false
      argument :sentiment_hide_logo, Boolean, required: false
      argument :sentiment_schedule, String, required: false

      type Types::Feedback::Feedback

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(**args)
        feedback = fetch_or_create_feedback

        args.delete(:nps_hide_logo) if args[:nps_hide_logo] && @site.plan.free?
        args.delete(:sentiment_hide_logo) if args[:sentiment_hide_logo] && @site.plan.free?

        feedback.assign_attributes(args.except(:site_id))

        force_array_updates(feedback, args)

        feedback.save

        feedback
      end

      private

      def fetch_or_create_feedback
        @site.feedback || ::Feedback.create(
          site_id: @site.id,
          nps_enabled: false,
          nps_accent_color: '#0074E0',
          nps_schedule: 'once',
          nps_phrase: @site.name,
          nps_follow_up_enabled: true,
          nps_contact_consent_enabled: false,
          nps_layout: 'full_width',
          nps_excluded_pages: [],
          nps_languages: ['en'],
          nps_languages_default: 'en',
          nps_hide_logo: false,
          sentiment_enabled: false,
          sentiment_accent_color: '#0074E0',
          sentiment_excluded_pages: [],
          sentiment_layout: 'right_middle',
          sentiment_devices: %w[desktop tablet],
          sentiment_hide_logo: false,
          sentiment_schedule: 'always'
        )
      end

      def force_array_updates(feedback, args)
        feedback.nps_excluded_pages_will_change! if args[:nps_excluded_pages]
        feedback.sentiment_excluded_pages_will_change! if args[:sentiment_excluded_pages]
        feedback.nps_languages_will_change! if args[:nps_languages]
      end
    end
  end
end
