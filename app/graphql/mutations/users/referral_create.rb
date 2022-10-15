# frozen_string_literal: true

module Mutations
  module Users
    class ReferralCreate < UserMutation
      null true

      graphql_name 'UsersReferralCreate'

      argument :url, String, required: true

      type Types::Users::Referral

      def resolve(url:)
        return unless @user.partner

        Referral.create!(url:, partner: @user.partner)
      end
    end
  end
end
