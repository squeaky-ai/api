# frozen_string_literal: true

module Resolvers
  module Sites
    class Referrers < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve_with_timings
        DataCacheService::Sites::Referrers.new(site_id: object[:id]).call
      end
    end
  end
end
