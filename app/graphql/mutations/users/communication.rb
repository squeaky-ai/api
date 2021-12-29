# frozen_string_literal: true

module Mutations
  module Users
    class Communication < UserMutation
      null true

      graphql_name 'UsersCommunication'

      argument :onboarding_email, Boolean, required: false
      argument :weekly_review_email, Boolean, required: false
      argument :monthly_review_email, Boolean, required: false
      argument :product_updates_email, Boolean, required: false
      argument :marketing_and_special_offers_email, Boolean, required: false
      argument :knowledge_sharing_email, Boolean, required: false

      type Types::Users::Communication

      def resolve(**args)
        communication = @user.communication || ::Communication.create(
          user_id: @user.id,
          onboarding_email: true,
          weekly_review_email: true,
          monthly_review_email: true,
          product_updates_email: true,
          marketing_and_special_offers_email: true,
          knowledge_sharing_email: true
        )

        communication.assign_attributes(args)
        communication.save

        communication
      end
    end
  end
end
