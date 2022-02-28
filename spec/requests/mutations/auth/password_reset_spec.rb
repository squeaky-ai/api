# frozen_string_literal: true

require 'rails_helper'

auth_password_reset_mutation = <<-GRAPHQL
  mutation($email: String!) {
    authPasswordReset(input: { email: $email }) {
      message
    }
  }
GRAPHQL

RSpec.describe Mutations::Auth::PasswordReset, type: :request do
  context 'when the user does not exist' do
    subject do
      variables = {
        email: 'dsfsdfsdfdsfsd@gmail.com'
      }
      graphql_request(auth_password_reset_mutation, variables, nil)
    end

    it 'returns an error' do
      response = subject['errors'][0]['message']
      expect(response).to eq 'Email not found'
    end
  end

  context 'when the user exists' do
    let(:user) { create(:user) }

    before { user }

    subject do
      variables = {
        email: user.email
      }
      graphql_request(auth_password_reset_mutation, variables, nil)
    end

    it 'returns a success message' do
      response = subject['data']['authPasswordReset']
      expect(response).to eq('message' => 'Password reset sent')
    end

    it 'sends an email' do
      expect { subject }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
