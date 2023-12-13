# frozen_string_literal: true

module Mutations
  module Admin
    class ReferralDelete < AdminMutation
      null true

      graphql_name 'AdminReferralDelete'

      argument :id, ID, required: true

      type Types::Users::Referral

      def resolve(id:)
        referral = Referral.find(id)

        return referral if referral.site

        referral.destroy!

        nil
      end
    end
  end
end
