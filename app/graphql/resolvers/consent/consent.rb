# frozen_string_literal: true

module Resolvers
  module Consent
    class Consent < Resolvers::Base
      type Types::Consent::Consent, null: true

      argument :site_id, String, required: true

      def resolve_with_timings(site_id:)
        Site.find_by(uuid: site_id)&.consent
      end
    end
  end
end
