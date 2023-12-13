# frozen_string_literal: true

module Resolvers
  module Sites
    class Referrers < Resolvers::Base
      type [String, { null: false }], null: false

      def resolve
        DataCacheService::Sites::Referrers.new(site: object).call
      end
    end
  end
end
