# frozen_string_literal: true

module Resolvers
  module Admin
    class Sites < Resolvers::Base
      type [Types::Sites::Site, { null: true }], null: false

      def resolve_with_timings
        ::Site.includes(%i[teams users]).all
      end
    end
  end
end
