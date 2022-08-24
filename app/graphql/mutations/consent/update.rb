# frozen_string_literal: true

module Mutations
  module Consent
    class Update < SiteMutation
      null false

      graphql_name 'ConsentUpdate'

      argument :site_id, ID, required: true
      argument :name, String, required: false
      argument :privacy_policy_url, String, required: false
      argument :layout, String, required: false
      argument :languages, [String], required: false
      argument :languages_default, String, required: false
      argument :consent_method, String, required: false

      type Types::Consent::Consent

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(**args)
        consent = fetch_or_create_consent

        consent.assign_attributes(args.except(:site_id))
        consent.languages_will_change! if args[:languages]
        consent.save

        consent
      end

      private

      def fetch_or_create_consent
        @site.consent || ::Consent.create_with_defaults(@site)
      end
    end
  end
end
