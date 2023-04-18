# typed: false
# frozen_string_literal: true

require 'rails_helper'

user_exists_query = <<-GRAPHQL
  query($email: String!) {
    userExists(email: $email)
  }
GRAPHQL

RSpec.describe Resolvers::Users::UserExists, type: :request do
  context 'when the user does not exist' do
    let(:email) { 'jimmy@gmail.com' }

    it 'returns false' do
      response = graphql_request(user_exists_query, { email: email }, nil)

      expect(response['data']['userExists']).to eq false
    end
  end

  context 'when the user does exist' do
    let(:email) { 'jimmy@gmail.com' }

    before { create(:user, email: email) }

    it 'returns true' do
      response = graphql_request(user_exists_query, { email: email }, nil)

      expect(response['data']['userExists']).to eq true
    end
  end
end
