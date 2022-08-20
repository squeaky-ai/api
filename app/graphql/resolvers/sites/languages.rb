# frozen_string_literal: true

module Resolvers
  module Sites
    class Languages < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve_with_timings
        DataCacheService::Sites::Languages.new(site: object).call
      end
    end
  end
end
