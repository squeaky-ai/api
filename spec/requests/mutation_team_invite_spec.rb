# frozen_string_literal: true

require 'rails_helper'

team_invite_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $email: String!, $role: Int!) {
    teamInvite(input: { siteId: $site_id, email: $email, role: $role }) {
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

RSpec.describe 'Mutation site verify', type: :request do
  context 'when the invited user does not have an account' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user) }
    let(:email) { Faker::Internet.email }
    let(:subject) { graphql_request(team_invite_mutation, { site_id: site.id, email: email, role: 1 }, user) }

    before do
      stub = double
      allow(stub).to receive(:deliver_now)
      allow(TeamMailer).to receive(:invite).and_return(stub)
      allow(JsonWebToken).to receive(:encode).and_return '__jwt__'
    end

    it 'returns the invited user' do
      team = subject['data']['teamInvite']['team']
      invited_team_member = team.find { |t| t['user']['email'] == email }
      expect(invited_team_member).to be_truthy
    end

    it 'creates them an account' do
      subject
      invited_user = User.find_by(email: email)
      expect(invited_user).to be_truthy
      expect(invited_user.invited_at).to be_truthy
    end

    it 'sends an invite request to the email' do
      subject
      expect(TeamMailer).to have_received(:invite).with(email, site, user, '__jwt__')
    end
  end

  context 'when the user alredy has an account' do
    context 'and they are already a member' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user) }
      let(:invited_user) { create_user }

      let(:subject) do
        graphql_request(team_invite_mutation, { site_id: site.id, email: invited_user.email, role: 1 }, user)
      end

      before do
        create_team(user: invited_user, site: site, role: 1)

        stub = double
        allow(stub).to receive(:deliver_now)
        allow(TeamMailer).to receive(:invite).and_return(stub)
      end

      it 'does not add them a second time' do
        expect { subject }.not_to change { site.team.size }
      end

      it 'does not send an email' do
        subject
        expect(TeamMailer).not_to have_received(:invite)
      end
    end

    context 'and they are not a member' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user) }
      let(:invited_user) { create_user }

      let(:subject) do
        graphql_request(team_invite_mutation, { site_id: site.id, email: invited_user.email, role: 1 }, user)
      end

      before do
        stub = double
        allow(stub).to receive(:deliver_now)
        allow(TeamMailer).to receive(:invite).and_return(stub)
        allow(JsonWebToken).to receive(:encode).and_return '__jwt__'
      end

      it 'returns the added team member' do
        team = subject['data']['teamInvite']['team']
        invited_team_member = team.find { |t| t['user']['email'] == invited_user.email }
        expect(invited_team_member).to be_truthy
      end

      it 'adds them to the team' do
        expect { subject }.to change { site.team.size }.from(1).to(2)
      end

      it 'sends an invite request to the email' do
        subject
        expect(TeamMailer).to have_received(:invite).with(invited_user.email, site, user, '__jwt__')
      end
    end
  end
end
