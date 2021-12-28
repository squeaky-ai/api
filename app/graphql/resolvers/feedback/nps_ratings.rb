# frozen_string_literal: true

module Resolvers
  module Feedback
    class NpsRatings < Resolvers::Base
      type [Types::Feedback::NpsRating, { null: true }], null: false

      def resolve
        Nps
          .joins(:recording)
          .where(
            'recordings.site_id = ? AND nps.created_at::date >= ? AND nps.created_at::date <= ? AND recordings.status IN (?)',
            object[:site_id],
            object[:from_date],
            object[:to_date],
            [Recording::ACTIVE, Recording::DELETED]
          )
          .select('nps.score')
      end
    end
  end
end
