# frozen_string_literal: true

require 'rails_helper'

user_admin_query = <<-GRAPHQL
  query($user_id: ID!) {
    admin {
      user(userId: $user_id) {
        id
        firstName
        lastName
        email
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Admin::Users, type: :request do
  let(:user_id) { 4234234234 }

  subject { graphql_request(user_admin_query, { user_id: }, user) }

  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      expect(subject['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser' do
    context 'and the user does not exist' do
      let(:user) { create(:user, superuser: true) }

      it 'returns nil' do
        expect(subject['data']['admin']['user']).to eq(nil)
      end
    end

    context 'and the user exists' do
      let(:user) { create(:user, superuser: true) }
      let(:queried_user) { create(:user) }
      let(:user_id) { queried_user.id }

      it 'returns the user' do
        expect(subject['data']['admin']['user']).to eq(
          'id' => queried_user.id.to_s,
          'email' => queried_user.email,
          'firstName' => queried_user.first_name,
          'lastName' => queried_user.last_name
        )
      end
    end
  end
end
