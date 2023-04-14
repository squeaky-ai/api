# typed: false
# frozen_string_literal: true

require 'rails_helper'

auth_reconfirm_mutation = <<-GRAPHQL
  mutation($input: AuthReconfirmInput!) {
    authReconfirm(input: $input) {
      message
    }
  }
GRAPHQL

RSpec.describe Mutations::Auth::Confirm, type: :request do
  context 'when the user does not exist' do
    subject do
      variables = {
        input: {
          email: 'dsfsdfsdfdsfsd@gmail.com'
        }
      }
      graphql_request(auth_reconfirm_mutation, variables, nil)
    end

    it 'returns an error' do
      response = subject['errors'][0]['message']
      expect(response).to eq 'Email not found'
    end
  end

  context 'when the user exists but they are already confirmed' do
    let(:user) { create(:user) }

    before { user.confirm }

    subject do
      variables = {
        input: {
          email: user.email
        }
      }
      graphql_request(auth_reconfirm_mutation, variables, nil)
    end

    it 'returns an error' do
      response = subject['errors'][0]['message']
      expect(response).to eq 'Email was already confirmed, please try signing in'
    end
  end

  context 'when the user exists but has not confirmed' do
    let!(:user) { create(:user, confirmed_at: nil) }

    subject do
      variables = {
        input: {
          email: user.email
        }
      }
      graphql_request(auth_reconfirm_mutation, variables, nil)
    end

    it 'returns a success message' do
      response = subject['data']['authReconfirm']
      expect(response).to eq('message' => 'Reconfirmation sent')
    end

    it 'sends an email' do
      expect { subject }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
