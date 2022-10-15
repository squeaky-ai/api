# frozen_string_literal: true

module Mutations
  module Users
    class ReferralDelete < UserMutation
      null true

      graphql_name 'UsersReferralDelete'

      argument :id, ID, required: true

      type Types::Users::Referral

      def resolve(id:)
        return unless @user.partner

        referral = @user.partner.referrals.find(id)

        return referral if referral.site

        referral.destroy!

        nil
      end
    end
  end
end
