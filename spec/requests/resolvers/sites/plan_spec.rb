# frozen_string_literal: true

require 'rails_helper'

site_plan_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      plan {
        type
        name
        exceeded
        billingValid
        recordingsLimit
        recordingsLocked
        visitorsLocked
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::Plan, type: :request do
  context 'when the site has not exceeded the limit' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_plan_query, variables, user)
    end

    it 'returns the plan' do
      response = subject['data']['site']['plan']
      expect(response).to eq(
        'type' => 0,
        'name' => 'Free',
        'exceeded' => false,
        'billingValid' => true,
        'recordingsLimit' => 1000,
        'recordingsLocked' => 0,
        'visitorsLocked' => 0
      )
    end
  end

  context 'when the site has exceeded the limit' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before { allow_any_instance_of(Resolvers::Sites::Plan).to receive(:recordings_locked_count).and_return(50) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_plan_query, variables, user)
    end

    it 'returns the plan' do
      response = subject['data']['site']['plan']
      expect(response).to eq(
        'type' => 0,
        'name' => 'Free',
        'exceeded' => true,
        'billingValid' => true,
        'recordingsLimit' => 1000,
        'recordingsLocked' => 50,
        'visitorsLocked' => 0
      )
    end
  end

  context 'when they are on the free plan and the billing is invalid' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user, plan: 0) }

    before do
      create(:billing, site: site, user: user, status: Billing::INVALID)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_plan_query, variables, user)
    end

    it 'returns the plan' do
      response = subject['data']['site']['plan']
      expect(response).to eq(
        'type' => 0,
        'name' => 'Free',
        'exceeded' => false,
        'billingValid' => true,
        'recordingsLimit' => 1000,
        'recordingsLocked' => 0,
        'visitorsLocked' => 0
      )
    end
  end

  context 'when they are not on the free plan and the billing is invalid' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user, plan: 1) }

    before do
      create(:billing, site: site, user: user, status: Billing::INVALID)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_plan_query, variables, user)
    end

    it 'returns the plan' do
      response = subject['data']['site']['plan']
      expect(response).to eq(
        'type' => 1,
        'name' => 'Light',
        'exceeded' => true,
        'billingValid' => false,
        'recordingsLimit' => 5000,
        'recordingsLocked' => 0,
        'visitorsLocked' => 0
      )
    end
  end
end
