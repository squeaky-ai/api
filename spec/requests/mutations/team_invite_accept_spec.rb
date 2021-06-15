# frozen_string_literal: true

require 'rails_helper'

team_invite_accept_mutation = <<-GRAPHQL
  mutation($token: String!, $password: String!) {
    teamInviteAccept(input: { token: $token, password: $password }) {
      id
      team {
        id
        role
        status
        user {
          id
          firstName
          lastName
          email
        }
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::TeamInviteAccept, type: :request do
  context 'when the token is not valid' do
    let(:token) { 'sdfdsfdsfdsf' }

    subject do
      variables = { token: token, password: Faker::String.random }
      graphql_request(team_invite_accept_mutation, variables, nil)
    end

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Team invite is invalid'
    end
  end

  context 'when the token is valid, but has been cancelled' do
    let(:site) { create_site }
    let(:user) { invite_user } # The team won't exist

    subject do
      variables = { token: user.raw_invitation_token, password: Faker::String.random }
      graphql_request(team_invite_accept_mutation, variables, nil)
    end

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Team invite has expired'
    end
  end

  context 'when the token is valid' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:team) { create_team(user: invite_user, site: site, role: Team::ADMIN, status: Team::PENDING) }

    subject do
      variables = { token: team.user.raw_invitation_token, password: Faker::String.random }
      graphql_request(team_invite_accept_mutation, variables, nil)
    end

    it 'returns the updated site' do
      response = subject['data']['teamInviteAccept']
      team_member = response['team'].find { |t| t['id'] == team.id.to_s }
      expect(response['id']).to eq site.id.to_s
      expect(team_member).not_to be nil
    end

    it 'updates the record' do
      expect { subject }.to change { site.team.size }.from(1).to(2)
    end
  end
end
