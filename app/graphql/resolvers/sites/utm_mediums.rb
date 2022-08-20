# frozen_string_literal: true

module Resolvers
  module Sites
    class UtmMediums < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve_with_timings
        DataCacheService::Sites::UtmMediums.new(site: object).call
      end
    end
  end
end
