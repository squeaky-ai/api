# frozen_string_literal: true

module Resolvers
  module Sites
    class Countries < Resolvers::Base
      type [Types::Recordings::Country, { null: true }], null: false

      def resolve_with_timings
        DataCacheService::Sites::Countries.new(site: object).call
      end
    end
  end
end
