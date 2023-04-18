# typed: false
# frozen_string_literal: true

module Resolvers
  module Partners
    class Partner < Resolvers::Base
      type String, null: true

      argument :slug, String, required: true

      def resolve_with_timings(slug:)
        ::Partner.find_by(slug:)&.name
      end
    end
  end
end
