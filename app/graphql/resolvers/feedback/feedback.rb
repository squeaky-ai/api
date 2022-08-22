# frozen_string_literal: true

module Resolvers
  module Feedback
    class Feedback < Resolvers::Base
      type Types::Feedback::Feedback, null: true

      argument :site_id, String, required: true

      def resolve_with_timings(site_id:)
        Site.find_by(uuid: site_id)&.feedback
      end
    end
  end
end
