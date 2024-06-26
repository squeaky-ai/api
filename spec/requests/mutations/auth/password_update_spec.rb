# frozen_string_literal: true

require 'rails_helper'

auth_password_update_mutation = <<-GRAPHQL
  mutation($input: AuthPasswordUpdateInput!) {
    authPasswordUpdate(input: $input) {
      id
      email
    }
  }
GRAPHQL

RSpec.describe Mutations::Auth::PasswordUpdate, type: :request do
  context 'when the reset token is invalid' do
    subject do
      variables = {
        input: {
          password: 'password',
          resetPasswordToken: 'asdasdasd'
        }
      }
      graphql_request(auth_password_update_mutation, variables, nil)
    end

    it 'returns an error' do
      response = subject['errors'][0]['message']
      expect(response).to eq 'Reset password token is invalid'
    end
  end

  context 'when the reset token is valid but the password is shit' do
    let(:user) { create(:user) }
    let(:reset_password_token) { user.send_reset_password_instructions }

    subject do
      variables = {
        input: {
          password: 'a',
          resetPasswordToken: reset_password_token
        }
      }
      graphql_request(auth_password_update_mutation, variables, nil)
    end

    it 'returns an error' do
      response = subject['errors'][0]['message']
      expect(response).to eq 'Password is too short (minimum is 6 characters)'
    end
  end

  context 'when the reset token is valid and the new password is good' do
    let(:user) { create(:user) }
    let(:reset_password_token) { user.send_reset_password_instructions }

    subject do
      variables = {
        input: {
          password: 'aaaa!!!!!!@@@@@vvvVVVVV',
          resetPasswordToken: reset_password_token
        }
      }
      graphql_request(auth_password_update_mutation, variables, nil)
    end

    it 'returns the user' do
      response = subject['data']['authPasswordUpdate']
      expect(response).to eq(
        'id' => user.id.to_s,
        'email' => user.email
      )
    end
  end
end
