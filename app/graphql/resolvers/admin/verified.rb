# frozen_string_literal: true

module Resolvers
  module Admin
    class Verified < Resolvers::Base
      type Types::Admin::Verified, null: false

      def resolve
        dates = Site.select('verified_at').map(&:verified_at)
        verified = dates.compact

        {
          verified: verified.size,
          unverified: dates.size - verified.size
        }
      end
    end
  end
end
