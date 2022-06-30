# frozen_string_literal: true

module Resolvers
  module Sites
    class Countries < Resolvers::Base
      type [Types::Recordings::Country, { null: true }], null: false

      def resolve_with_timings
        DataCacheService::Sites::Countries.new(site_id: object[:id]).call
      end
    end
  end
end
