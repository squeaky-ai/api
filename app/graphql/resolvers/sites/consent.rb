# frozen_string_literal: true

module Resolvers
  module Sites
    class Consent < Resolvers::Base
      type Types::Consent::Consent, null: false

      def resolve_with_timings
        object.consent || ::Consent.create_with_defaults(object)
      end
    end
  end
end
