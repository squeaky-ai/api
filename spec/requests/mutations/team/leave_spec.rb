# frozen_string_literal: true

require 'rails_helper'

team_leave_mutation = <<-GRAPHQL
  mutation($input: TeamLeaveInput!) {
    teamLeave(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Teams::Leave, type: :request do
  context 'when the user is the owner' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { 
        input: {
          siteId: site.id
        }
      }
      graphql_request(team_leave_mutation, variables, user)
    end

    it 'returns the unmodified team' do
      expect(subject['data']['teamLeave']).not_to be_nil
    end

    it 'does not delete the user' do
      expect { subject }.not_to change { site.team.size }
    end
  end

  context 'when the user is not the owner' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team) }
    let(:team) { create(:team, user: user, site: site, role: Team::ADMIN) }

    subject do
      variables = { 
        input: {
          siteId: site.id 
        }
      }
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
