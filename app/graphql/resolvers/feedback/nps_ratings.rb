# frozen_string_literal: true

module Resolvers
  module Feedback
    class NpsRatings < Resolvers::Base
      type [Types::Feedback::NpsRating, { null: true }], null: false

      def resolve_with_timings
        Nps
          .joins(:recording)
          .where(
            'recordings.site_id = ? AND nps.created_at::date >= ? AND nps.created_at::date <= ?',
            object.site.id,
            object.range.from,
            object.range.to,
          )
          .select('nps.score')
      end
    end
  end
end
