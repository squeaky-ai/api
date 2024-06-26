# frozen_string_literal: true

module Resolvers
  module Sites
    class Countries < Resolvers::Base
      type [Types::Recordings::Country, { null: false }], null: false

      def resolve
        DataCacheService::Sites::Countries.new(site: object).call
      end
    end
  end
end
