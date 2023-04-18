# frozen_string_literal: true

module Resolvers
  module Sites
    class Browsers < Resolvers::Base
      type [String, { null: false }], null: false

      def resolve_with_timings
        DataCacheService::Sites::Browsers.new(site: object).call
      end
    end
  end
end
