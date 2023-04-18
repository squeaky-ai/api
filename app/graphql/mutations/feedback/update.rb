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
      argument :sentiment_languages, [String], required: false
      argument :sentiment_languages_default, String, required: false

      type Types::Feedback::Feedback

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve_with_timings(**args)
        feedback = fetch_or_create_feedback

        args.delete(:nps_hide_logo) if args[:nps_hide_logo] && site.plan.free?
        args.delete(:sentiment_hide_logo) if args[:sentiment_hide_logo] && site.plan.free?

        feedback.assign_attributes(args.except(:site_id))

        force_array_updates(feedback, args)

        feedback.save

        feedback
      end

      private

      def fetch_or_create_feedback
        site.feedback || ::Feedback.create_with_defaults(site)
      end

      def force_array_updates(feedback, args)
        feedback.nps_excluded_pages_will_change! if args[:nps_excluded_pages]
        feedback.sentiment_excluded_pages_will_change! if args[:sentiment_excluded_pages]
        feedback.nps_languages_will_change! if args[:nps_languages]
        feedback.sentiment_languages_will_change! if args[:sentiment_languages]
      end
    end
  end
end
