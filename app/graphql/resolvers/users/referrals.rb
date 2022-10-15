# frozen_string_literal: true

module Resolvers
  module Users
    class Referrals < Resolvers::Base
      type [Types::Users::Referral, { null: true }], null: false

      def resolve_with_timings
        Referral.includes(:site).where(partner_id: object.id)
      end
    end
  end
end
