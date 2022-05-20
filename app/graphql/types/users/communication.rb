# frozen_string_literal: true

module Types
  module Users
    class Communication < Types::BaseObject
      graphql_name 'UsersCommunication'

      field :id, ID, null: false
      field :onboarding_email, Boolean, null: false
      field :weekly_review_email, Boolean, null: false
      field :monthly_review_email, Boolean, null: false
      field :product_updates_email, Boolean, null: false
      field :marketing_and_special_offers_email, Boolean, null: false
      field :knowledge_sharing_email, Boolean, null: false
      field :feedback_email, Boolean, null: false
    end
  end
end
