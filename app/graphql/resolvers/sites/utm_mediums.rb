# frozen_string_literal: true

module Resolvers
  module Sites
    class UtmMediums < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve_with_timings
        utm_mediums = Site
                      .find(object.id)
                      .recordings
                      .select(:utm_medium)
                      .where('utm_medium IS NOT NULL')
                      .distinct

        utm_mediums.map(&:utm_medium)
      end
    end
  end
end
