# typed: false
# frozen_string_literal: true

require 'rails_helper'

user_query = <<-GRAPHQL
  query {
    user {
      id
      firstName
      lastName
      email
    }
  }
GRAPHQL

RSpec.describe Resolvers::Users::User, type: :request do
  context 'when there is no current_user' do
    it 'returns null' do
      response = graphql_request(user_query, {}, nil)

      expect(response['data']['user']).to be_nil
    end
  end

  context 'when there is a current_user' do
    let(:user) { create(:user) }

    subject {  response = graphql_request(user_query, {}, user) }

    it 'returns the user' do
      expect(subject['data']['user']).to eq(
        {
          'id' => user.id.to_s,
          'firstName' => user.first_name,
          'lastName' => user.last_name,
          'email' => user.email
        }
      )
    end

    it 'updates the last_activity_at' do
      expect { subject }.to change { user.last_activity_at.nil? }.from(true).to(false)
    end
  end
end
