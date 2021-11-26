# frozen_string_literal: true

require 'rails_helper'

team_leave_mutation = <<-GRAPHQL
  mutation($site_id: ID!) {
    teamLeave(input: { siteId: $site_id }) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Teams::Leave, type: :request do
  context 'when the user is the owner' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(team_leave_mutation, variables, user)
    end

    it 'returns the unmodified site' do
      expect(subject['data']['teamLeave']['id']).to eq site.id.to_s
    end

    it 'does not delete the user' do
      expect { subject }.not_to change { site.team.size }
    end
  end

  context 'when the user is not the owner' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: create_user) }
    let(:team) { create_team(user: user, site: site, role: Team::ADMIN) }

    subject do
      variables = { site_id: site.id }
      graphql_request(team_leave_mutation, variables, user)
    end

    before do
      team
      stub = double
      allow(stub).to receive(:deliver_now)
      allow(TeamMailer).to receive(:member_left).and_return(stub)
    end

    it 'returns nil' do
      expect(subject['data']['teamLeave']).to be nil
    end

    it 'deletes the team' do
      subject
      expect { team.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'decrements the team size' do
      expect { subject }.to change { site.team.size }.from(2).to(1)
    end

    it 'sends an email to the owner' do
      subject
      expect(TeamMailer).to have_received(:member_left).with(site.owner.user.email, site, user).once
    end
  end
end
