# frozen_string_literal: true

require 'rails_helper'

communication_update_mutation = <<-GRAPHQL
  mutation ($input: UsersCommunicationInput!) {
    userCommunication(input: $input) {
      knowledgeSharingEmail
      marketingAndSpecialOffersEmail
      monthlyReviewEmail
      onboardingEmail
      productUpdatesEmail
      weeklyReviewEmail
    }
  }
GRAPHQL

RSpec.describe Mutations::Users::Communication, type: :request do
  context 'when there is nothing in the database' do
    let(:user) { create(:user) }

    subject do
      variables = {
        input: {
          onboardingEmail: true,
          weeklyReviewEmail: true,
          monthlyReviewEmail: true,
          productUpdatesEmail: true,
          marketingAndSpecialOffersEmail: true,
          knowledgeSharingEmail: true,
        }
      }
      graphql_request(communication_update_mutation, variables, user)
    end

    it 'returns the data' do
      expect(subject['data']['userCommunication']).to eq(
        'onboardingEmail' => true,
        'weeklyReviewEmail' => true,
        'monthlyReviewEmail' => true,
        'productUpdatesEmail' => true,
        'marketingAndSpecialOffersEmail' => true,
        'knowledgeSharingEmail' => true
      )
    end

    it 'upserts the record' do
      expect { subject }.to change { user.reload.communication.nil? }.from(true).to(false)
    end
  end

  context 'when there is something in the database' do
    let(:user) { create(:user) }

    before do
      Communication.create(
        user_id: user.id,
        onboarding_email: true,
        weekly_review_email: true,
        monthly_review_email: true,
        product_updates_email: true,
        marketing_and_special_offers_email: true,
        knowledge_sharing_email: true
      )
    end

    subject do
      variables = {
        input: {
          productUpdatesEmail: false,
          marketingAndSpecialOffersEmail: false,
          knowledgeSharingEmail: false
        }
      }
      graphql_request(communication_update_mutation, variables, user)
    end

    it 'returns the data' do
      expect(subject['data']['userCommunication']).to eq(
        'onboardingEmail' => true,
        'weeklyReviewEmail' => true,
        'monthlyReviewEmail' => true,
        'productUpdatesEmail' => false,
        'marketingAndSpecialOffersEmail' => false,
        'knowledgeSharingEmail' => false
      )
    end

    it 'does not create a new record' do
      expect { subject }.not_to change { user.reload.communication.nil? }
    end
  end
end
