# frozen_string_literal: true

require 'rails_helper'

auth_confirm_mutation = <<-GRAPHQL
  mutation($input: AuthConfirmInput!) {
    authConfirm(input: $input) {
      id
      email
    }
  }
GRAPHQL

RSpec.describe Mutations::Auth::Confirm, type: :request do
  context 'when there is no user matching the token' do
    subject do
      variables = {
        input: {
          token: 'dsfsdfsdfdsfsd'
        }
      }
      graphql_request(auth_confirm_mutation, variables, nil)
    end

    it 'returns an error' do
      response = subject['errors'][0]['message']
      expect(response).to eq 'Confirmation token is invalid'
    end
  end

  context 'when the  token is valid' do
    let(:user) { create(:user, confirmed_at: nil) }

    subject do
      variables = {
        input: {
          token: user.confirmation_token
        }
      }
      graphql_request(auth_confirm_mutation, variables, nil)
    end

    it 'returns the user' do
      response = subject['data']['authConfirm']

      expect(response).to eq(
        'id' => user.id.to_s,
        'email' => user.email
      )
    end
  end
end
