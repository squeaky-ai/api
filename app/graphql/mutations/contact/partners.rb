# frozen_string_literal: true

module Mutations
  module Contact
    class Partners < BaseMutation
      null true

      graphql_name 'ContactPartners'

      argument :first_name, String, required: true
      argument :last_name, String, required: true
      argument :email, String, required: true
      argument :name, String, required: true
      argument :description, String, required: false
      argument :client_count, String, required: false

      type Types::Common::GenericSuccess

      def resolve_with_timings(first_name:, last_name:, email:, name:, description:, client_count:) # rubocop:disable Metrics/ParameterLists
        ContactMailer.partners(
          first_name:,
          last_name:,
          email:,
          name:,
          description:,
          client_count:
        ).deliver_now

        {
          message: 'Sent'
        }
      end
    end
  end
end
