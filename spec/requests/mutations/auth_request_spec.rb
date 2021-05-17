# frozen_string_literal: true

require 'rails_helper'

auth_request_mutation = <<-GRAPHQL
  mutation($email: String!, $auth_type: Auth!) {
    authRequest(input: { email: $email, authType: $auth_type }) {
      emailSentAt
    }
  }
GRAPHQL

RSpec.describe Mutations::AuthRequest, type: :request do
  context 'when the AuthType is LOGIN' do
    context 'and the user does not have an account' do
      let(:email) { Faker::Internet.email }

      subject do
        variables = { email: email, auth_type: 'LOGIN' }
        graphql_request(auth_request_mutation, variables, nil)
      end

      it 'raises an error' do
        expect(subject['errors'][0]['message']).to eq 'User account does not exist'
      end
    end

    context 'and the user has an account' do
      let(:user) { create_user }
      let(:token) { '123456' }

      subject do
        variables = { email: user.email, auth_type: 'LOGIN' }
        graphql_request(auth_request_mutation, variables, nil)
      end

      before do
        stub = double
        allow(stub).to receive(:deliver_now)
        allow(AuthMailer).to receive(:login).and_return(stub)
        allow_any_instance_of(OneTimePassword).to receive(:generate_token).and_return(token)
      end

      it 'returns a timestamp for when the email was sent' do
        expect(subject['data']['authRequest']['emailSentAt']).not_to be nil
      end

      it 'sends an email' do
        subject
        expect(AuthMailer).to have_received(:login).with(user.email, token)
      end

      it 'stores the token in redis' do
        subject
        stored_token = Redis.current.get("auth:#{user.email}")
        expect(token).to eq stored_token
      end
    end
  end

  context 'when the AuthType is SIGNUP' do
    context 'and the user does not have an account' do
      let(:email) { Faker::Internet.email }
      let(:token) { '123456' }

      subject do
        variables = { email: email, auth_type: 'SIGNUP' }
        graphql_request(auth_request_mutation, variables, nil)
      end

      before do
        stub = double
        allow(stub).to receive(:deliver_now)
        allow(AuthMailer).to receive(:signup).and_return(stub)
        allow_any_instance_of(OneTimePassword).to receive(:generate_token).and_return(token)
      end

      it 'returns a timestamp for when the email was sent' do
        expect(subject['data']['authRequest']['emailSentAt']).not_to be nil
      end

      it 'sends an email' do
        subject
        expect(AuthMailer).to have_received(:signup).with(email, token)
      end

      it 'stores the token in redis' do
        subject
        stored_token = Redis.current.get("auth:#{email}")
        expect(token).to eq stored_token
      end
    end

    context 'and the user has an account' do
      let(:user) { create_user }

      subject do
        variables = { email: user.email, auth_type: 'SIGNUP' }
        graphql_request(auth_request_mutation, variables, nil)
      end

      it 'raises an error' do
        expect(subject['errors'][0]['message']).to eq 'User account already exists'
      end
    end
  end
end
