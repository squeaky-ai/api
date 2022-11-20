# frozen_string_literal: true

module Mutations
  module Contact
    class Startups < BaseMutation
      null true

      graphql_name 'ContactStartups'

      argument :first_name, String, required: true
      argument :last_name, String, required: true
      argument :email, String, required: true
      argument :name, String, required: true
      argument :years_active, String, required: false
      argument :traffic_count, String, required: false

      type Types::Common::GenericSuccess

      def resolve_with_timings(first_name:, last_name:, email:, name:, years_active:, traffic_count:) # rubocop:disable Metrics/ParameterLists
        ContactMailer.startups(
          first_name:,
          last_name:,
          email:,
          name:,
          years_active:,
          traffic_count:
        ).deliver_now

        {
          message: 'Sent'
        }
      end
    end
  end
end
