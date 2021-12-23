# frozen_string_literal: true

module Resolvers
  module Sites
    class Referrers < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve
        referrers = Site
                    .find(object.id)
                    .recordings
                    .select(:referrer)
                    .where('referrer IS NOT NULL')

        referrers.map(&:referrer).uniq
      end
    end
  end
end
