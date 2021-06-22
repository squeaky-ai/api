# frozen_string_literal: true

require 'rails_helper'

user_invitation = <<-GRAPHQL
  query($token: String!) {
    userInvitation(token: $token) {
      email
      hasPending
    }
  }
GRAPHQL

RSpec.describe 'QueryUserInvitation', type: :request do
  context 'when there is no user invitation' do
    subject do
      graphql_request(user_invitation, { token: Faker::String.random }, nil)
    end

    it 'returns no email and pending status' do
      expect(subject['data']['userInvitation']).to eq(
        'email' => nil,
        'hasPending' => false
      )
    end
  end

  context 'when there is a user invitation' do
    let(:user) { create_user }

    subject do
      user.invite_to_team!
      graphql_request(user_invitation, { token: user.raw_invitation_token }, nil)
    end

    before { create_site_and_team(user: user, status: Team::PENDING) }

    it 'returns the email and pending status' do
      expect(subject['data']['userInvitation']).to eq(
        {
          'email' => user.email,
          'hasPending' => true
        }
      )
    end
  end

  context 'when there is a user invitation but it has been revoked' do
    let(:user) { create_user }

    subject do
      user.invite_to_team!
      graphql_request(user_invitation, { token: user.raw_invitation_token }, nil)
    end

    it 'returns the email and pending status' do
      expect(subject['data']['userInvitation']).to eq(
        {
          'email' => user.email,
          'hasPending' => false
        }
      )
    end
  end
end
