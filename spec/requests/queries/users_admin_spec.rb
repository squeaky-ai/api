# frozen_string_literal: true

require 'rails_helper'

users_admin_query = <<-GRAPHQL
  query {
    usersAdmin {
      id
      firstName
      lastName
      email
    }
  }
GRAPHQL

RSpec.describe 'QueryUsersAdmin', type: :request do
  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      response = graphql_request(users_admin_query, {}, user)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser' do
    let(:user) { create(:user, superuser: true) }

    before do
      create(:user)
      create(:user)
    end

    it 'returns all the users' do
      response = graphql_request(users_admin_query, {}, user)

      expect(response['data']['usersAdmin'].size).to eq 3
    end
  end
end
