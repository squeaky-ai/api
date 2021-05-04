# frozen_string_literal: true

require 'faker'
require 'rails_helper'

QUERY = <<-GRAPHQL
  query {
    user {
      id
      firstName
      lastName
      email
    }
  }
GRAPHQL

RSpec.describe 'Query User', type: :request do
  context 'when no bearer token is provided' do
    it 'returns null' do
      response = graphql_query(QUERY)
      body = response['data']['user']

      expect(body).to be_nil
    end
  end

  context 'when the bearer token is provided' do
    let(:user) do
      User.create(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: Faker::Internet.email
      )
    end
    let(:token) { JsonWebToken.encode({ id: user.id }) }

    it 'returns the user' do
      result = graphql_query(QUERY, { 'Authorization': "Bearer #{token}" })
      body = result['data']['user']

      expect(body['id']).to eq(user.id.to_s)
      expect(body['firstName']).to eq(user.first_name)
      expect(body['lastName']).to eq(user.last_name)
      expect(body['email']).to eq(user.email)
    end
  end
end
