# frozen_string_literal: true

module Resolvers
  module Sites
    class UtmTerms < Resolvers::Base
      type [String, { null: false }], null: false

      def resolve
        DataCacheService::Sites::UtmTerms.new(site: object).call
      end
    end
  end
end
