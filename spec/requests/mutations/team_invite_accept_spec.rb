# frozen_string_literal: true

require 'rails_helper'

team_invite_accept_mutation = <<-GRAPHQL
  mutation($token: String!) {
    teamInviteAccept(input: { token: $token }) {
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
    let(:subject) { graphql_request(team_invite_accept_mutation, { token: token }, nil) }

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Team invite is invalid'
    end
  end

  context 'when the token has expired' do
    let(:site) { create_site }
    let(:token) { JsonWebToken.encode({ site_id: site.id, team_id: 9345 }, 1.month.ago) }
    let(:subject) { graphql_request(team_invite_accept_mutation, { token: token }, nil) }

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Team invite has expired'
    end
  end

  context 'when the token is valid, but has been cancelled' do
    let(:site) { create_site }
    let(:token) { JsonWebToken.encode({ site_id: site.id, team_id: 9345 }) } # The team won't exist
    let(:subject) { graphql_request(team_invite_accept_mutation, { token: token }, nil) }

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Team invite has expired'
    end
  end

  context 'when the token is valid' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:team) { create_team(user: create_user, site: site, role: Team::ADMIN, status: Team::PENDING) }
    let(:token) { JsonWebToken.encode({ site_id: site.id, team_id: team.id }) }
    let(:subject) { graphql_request(team_invite_accept_mutation, { token: token }, nil) }

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
