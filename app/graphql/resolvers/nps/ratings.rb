# frozen_string_literal: true

module Resolvers
  module Nps
    class Ratings < Resolvers::Base
      type [Types::Nps::Rating, { null: true }], null: false

      def resolve
        Nps
          .joins(:recording)
          .where('recordings.site_id = ? AND nps.created_at::date >= ? AND nps.created_at::date <= ?', object.site_id, object.from_date, object.to_date)
          .select('nps.score')
      end
    end
  end
end
