# frozen_string_literal: true

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
  context 'when there is no current_user' do
    it 'returns null' do
      response = graphql_query(QUERY, {}, nil)

      expect(response['data']['user']).to be_nil
    end
  end

  context 'when there is a current_user' do
    let(:user) { create_user }

    it 'returns the user' do
      response = graphql_query(QUERY, {}, user)

      expect(response['data']['user']).to eq(
        {
          'id' => user.id.to_s,
          'firstName' => user.first_name,
          'lastName' => user.last_name,
          'email' => user.email
        }
      )
    end
  end
end
