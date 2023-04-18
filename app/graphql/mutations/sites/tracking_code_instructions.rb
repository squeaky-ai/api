# typed: false
# frozen_string_literal: true

module Mutations
  module Sites
    class TrackingCodeInstructions < SiteMutation
      null false

      graphql_name 'SitesTrackingCodeInstructions'

      argument :site_id, ID, required: true
      argument :first_name, String, required: true
      argument :email, String, required: true

      type Types::Common::GenericSuccess

      def permitted_roles
        [Team::OWNER]
      end

      def resolve_with_timings(first_name:, email:)
        SiteMailer.tracking_code_instructions(site, first_name, email).deliver_now
        { message: 'Email sent' }
      end
    end
  end
end
