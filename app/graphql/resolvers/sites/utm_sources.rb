# frozen_string_literal: true

module Resolvers
  module Sites
    class UtmSources < Resolvers::Base
      type [String, { null: false }], null: false

      def resolve
        DataCacheService::Sites::UtmSources.new(site: object).call
      end
    end
  end
end
