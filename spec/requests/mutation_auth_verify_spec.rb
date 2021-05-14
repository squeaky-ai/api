# frozen_string_literal: true

require 'rails_helper'

auth_verify_mutation = <<-GRAPHQL
  mutation($email: String!, $token: String!) {
    authVerify(input: { email: $email, token: $token }) {
      jwt
    }
  }
GRAPHQL

RSpec.describe 'Mutation auth request', type: :request do
  context 'when there is no token stored for this user' do
    let(:email) { Faker::Internet.email }
    let(:token) { '123456' }
    let(:subject) { graphql_request(auth_verify_mutation, { email: email, token: token }, nil) }

    it 'raises an error' do
      expect(subject['errors'][0]['message']).to eq 'Token is incorrect or has expired'
    end
  end

  context 'when there is a token stored but it does not match' do
    let(:email) { Faker::Internet.email }
    let(:token) { '123456' }
    let(:subject) { graphql_request(auth_verify_mutation, { email: email, token: token }, nil) }

    before { Redis.current.set("auth:#{email}", '654321') }

    it 'raises an error' do
      expect(subject['errors'][0]['message']).to eq 'Token is incorrect or has expired'
    end
  end

  context 'when there is a token and it is valid' do
    context 'and the user already has an account' do
      let(:user) { create_user }
      let(:token) { '123456' }
      let(:subject) { graphql_request(auth_verify_mutation, { email: user.email, token: token }, nil) }

      before do
        Redis.current.set("auth:#{user.email}", token)
        allow(User).to receive(:create)
      end

      it 'returns a jwt' do
        expect(subject['data']['authVerify']['jwt']).not_to be nil
      end

      it 'sets the last sign in time' do
        subject
        expect(user.reload.last_signed_in_at).not_to be nil
      end

      it 'does not create a user' do
        subject
        expect(User).not_to have_received(:create)
      end
    end

    context 'and the user does not have an account' do
      let(:email) { Faker::Internet.email }
      let(:token) { '123456' }
      let(:subject) { graphql_request(auth_verify_mutation, { email: email, token: token }, nil) }

      before do
        Redis.current.set("auth:#{email}", token)
        allow(User).to receive(:create).and_call_original
      end

      it 'returns a jwt' do
        expect(subject['data']['authVerify']['jwt']).not_to be nil
      end

      it 'does create a user' do
        subject
        expect(User).to have_received(:create)
      end
    end
  end
end
