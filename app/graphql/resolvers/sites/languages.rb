# frozen_string_literal: true

module Resolvers
  module Sites
    class Languages < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve_with_timings
        languges = Site
                   .find(object.id)
                   .recordings
                   .select(:locale)

        languges.map(&:language).uniq
      end
    end
  end
end
