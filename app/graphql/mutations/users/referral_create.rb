# frozen_string_literal: true

module Mutations
  module Users
    class ReferralCreate < UserMutation
      null true

      graphql_name 'UsersReferralCreate'

      argument :url, String, required: true

      type Types::Users::Referral

      def resolve_with_timings(url:)
        return unless user.partner

        referral = Referral.create(url: uri(url), partner: user.partner)

        raise GraphQL::ExecutionError, referral.errors.full_messages.first unless referral.valid?

        referral
      end

      private

      def uri(url)
        formatted_uri = Site.format_uri(url)
        # This is quite important! The last thing we want
        # is nil://nil being in there and being unique!
        raise Exceptions::SiteInvalidUri unless formatted_uri

        formatted_uri
      end
    end
  end
end
