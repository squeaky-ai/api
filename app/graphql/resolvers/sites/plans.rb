# frozen_string_literal: true

module Resolvers
  module Sites
    class Plans < Resolvers::Base
      type [Types::Plans::Plan, { null: false }], null: false

      def resolve_with_timings
        ::Plans.to_a
      end
    end
  end
end
