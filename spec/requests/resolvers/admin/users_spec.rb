# typed: false
# frozen_string_literal: true

require 'rails_helper'

users_admin_query = <<-GRAPHQL
  query {
    admin {
      users {
        items {
          id
          firstName
          lastName
          email
        }
        pagination {
          pageSize
          total
          sort
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Admin::Users, type: :request do
  subject { graphql_request(users_admin_query, {}, user) }

  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      expect(subject['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser' do
    let(:user) { create(:user, superuser: true) }

    before do
      User.destroy_all

      create(:user)
      create(:user)
    end

    it 'returns all the users' do
      response = subject['data']['admin']['users']

      expect(response['items'].size).to eq 3
      expect(response['pagination']).to eq(
        'pageSize' => 25,
        'total' => 3,
        'sort' => 'created_at__desc'
      )
    end
  end
end
