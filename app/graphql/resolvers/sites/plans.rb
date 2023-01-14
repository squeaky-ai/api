# frozen_string_literal: true

module Resolvers
  module Sites
    class Plans < Resolvers::Base
      type [Types::Plans::DecoratedPlan, { null: false }], null: false

      def resolve_with_timings
        ::PlansDecorator.new(plans: ::Plans.to_a, site: nil).decrorate
      end
    end
  end
end
