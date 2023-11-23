# frozen_string_literal: true

require 'rails_helper'

site_delete_mutation = <<-GRAPHQL
  mutation($input: SitesDeleteInput!) {
    siteDelete(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Sites::Delete, type: :request do
  context 'when the user is not the owner' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team) }
    let!(:team) { create(:team, user:, site:, role: Team::ADMIN) }

    subject do
      variables = {
        input: {
          siteId: site.id
        }
      }
      graphql_request(site_delete_mutation, variables, user)
    end

    it 'raises an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'You lack the required permissions to do this'
    end

    it 'does not delete the site' do
      expect(site.reload).not_to be nil
    end

    it 'does not change the size of the team' do
      expect { subject }.not_to(change { site.team.size })
    end
  end

  context 'when the user is the owner' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let!(:recording_1) { create(:recording, site:) }
    let!(:recording_2) { create(:recording, site:) }

    subject do
      variables = {
        input: {
          siteId: site.id
        }
      }
      graphql_request(site_delete_mutation, variables, user)
    end

    before do
      create(:team, site:, role: Team::MEMBER)
      create(:team, site:, role: Team::MEMBER)
      create(:team, site:, role: Team::MEMBER)

      site.reload
    end

    it 'returns nil' do
      expect(subject['data']['siteDelete']).to be nil
    end

    it 'deletes the site' do
      subject
      expect { site.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'deletes the team members' do
      expect { subject }.to change { Team.where(site_id: site.id).size }.from(4).to(0)
    end

    it 'kicks off some jobs to clean up the recordings' do
      subject
      expect(RecordingDeleteJob).to have_been_enqueued.once.with(match_array([recording_1.id, recording_2.id]))
    end
  end

  context 'when there are other members in the team' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:user_1) { create(:user) }
    let(:user_2) { create(:user) }

    let!(:team_1) { create(:team, user:, site:, role: Team::OWNER) }
    let!(:team_2) { create(:team, user: user_1, site:, role: Team::ADMIN) }
    let!(:team_3) { create(:team, user: user_2, site:, role: Team::MEMBER) }

    before do
      stub = double
      allow(stub).to receive(:deliver_now)
      allow(SiteMailer).to receive(:destroyed).and_return(stub)
      allow(AdminMailer).to receive(:site_destroyed).and_return(stub)
    end

    subject do
      variables = {
        input: {
          siteId: site.id
        }
      }
      graphql_request(site_delete_mutation, variables, user)
    end

    it 'sends the email to the team members' do
      subject

      expect(SiteMailer).to have_received(:destroyed).with(team_1, site)
      expect(SiteMailer).to have_received(:destroyed).with(team_2, site)
      expect(SiteMailer).to have_received(:destroyed).with(team_3, site)
      expect(AdminMailer).to have_received(:site_destroyed).with(site)
    end
  end

  context 'when the site has billing' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:customer_id) { SecureRandom.base36 }

    before do
      Billing.create(customer_id:, site:, user:)
    end

    subject do
      variables = {
        input: {
          siteId: site.id
        }
      }
      graphql_request(site_delete_mutation, variables, user)
    end

    it 'deletes the stripe customer' do
      expect_any_instance_of(StripeService::Billing).to receive(:delete_customer)
      subject
    end
  end
end
