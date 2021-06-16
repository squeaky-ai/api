# frozen_string_literal: true

require 'rails_helper'

user_invitation = <<-GRAPHQL
  query($token: String!) {
    userInvitation(token: $token) {
      email
    }
  }
GRAPHQL

RSpec.describe 'QueryUserInvitation', type: :request do
  context 'when there is no user invitation' do
    it 'returns null' do
      response = graphql_request(user_invitation, { token: Faker::String.random }, nil)

      expect(response['data']['userInvitation']).to be_nil
    end
  end

  context 'when there is a user invitation' do
    let(:user) { invite_user }

    it 'returns the user' do
      response = graphql_request(user_invitation, { token: user.raw_invitation_token }, nil)

      expect(response['data']['userInvitation']).to eq(
        {
          'email' => user.email
        }
      )
    end
  end
end
