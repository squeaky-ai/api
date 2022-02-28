# frozen_string_literal: true

require 'rails_helper'

auth_reset_password_mutation = <<-GRAPHQL
  mutation($email: String!) {
    authResetPassword(input: { email: $email }) {
      message
    }
  }
GRAPHQL

RSpec.describe Mutations::Auth::ResetPassword, type: :request do
  context 'when the user does not exist' do
    subject do
      variables = {
        email: 'dsfsdfsdfdsfsd@gmail.com'
      }
      graphql_request(auth_reset_password_mutation, variables, nil)
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
      graphql_request(auth_reset_password_mutation, variables, nil)
    end

    it 'returns a success message' do
      response = subject['data']['authResetPassword']
      expect(response).to eq('message' => 'Password reset sent')
    end

    it 'sends an email' do
      expect { subject }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
