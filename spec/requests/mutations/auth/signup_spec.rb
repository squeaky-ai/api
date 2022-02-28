# frozen_string_literal: true

require 'rails_helper'

auth_signup_mutation = <<-GRAPHQL
  mutation($email: String!, $password: String!) {
    authSignup(input: { email: $email, password: $password }) {
      email
    }
  }
GRAPHQL

RSpec.describe Mutations::Auth::Signup, type: :request do
  context 'when the email is already in use' do
    let(:user) { create(:user) }

    subject do
      variables = {
        email: user.email,
        password: 'sdfsdfdssfd'
      }
      graphql_request(auth_signup_mutation, variables, nil)
    end

    it 'returns an error' do
      response = subject['errors'][0]['message']
      expect(response).to eq 'Email has already been taken'
    end
  end

  context 'when the email is not in use but the password is not good enough' do
    subject do
      variables = {
        email: 'sdfdsfsd@gmail.com',
        password: 'a'
      }
      graphql_request(auth_signup_mutation, variables, nil)
    end

    it 'returns an error' do
      response = subject['errors'][0]['message']
      expect(response).to eq 'Password is too short (minimum is 6 characters)'
    end
  end

  context 'when the email is not in use and the password is in use' do
    subject do
      variables = {
        email: 'sdfdsfsd@gmail.com',
        password: 'adfgdfg@2222££@£gbbb'
      }
      graphql_request(auth_signup_mutation, variables, nil)
    end

    it 'returns the user' do
      response = subject['data']['authSignup']
      expect(response).to eq('email' => 'sdfdsfsd@gmail.com')
    end

    it 'sends the email to confirm' do
      subject
      mail = ActionMailer::Base.deliveries.to_s
      expect(mail).to match 'Verify your email address'
    end
  end
end
