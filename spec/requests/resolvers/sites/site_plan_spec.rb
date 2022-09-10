# frozen_string_literal: true

require 'rails_helper'

site_plan_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      id
      plan {
        tier
        name
        exceeded
        invalid
        maxMonthlyRecordings
        dataStorageMonths
        responseTimeHours
        support
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::Plans, type: :request do
  context 'when the site is using the free tier' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        site_id: site.id
      }
      graphql_request(site_plan_query, variables, user)
    end

    it 'returns the default plan for this tier' do
      response = subject['data']['site']['plan']
      expect(response).to eq(
        'tier' => 0,
        'name' => 'Free',
        'exceeded' => false,
        'invalid' => false,
        'maxMonthlyRecordings' => 1000,
        'dataStorageMonths' => 6,
        'responseTimeHours' => 168,
        'support' => [
          'Email'
        ]
      )
    end
  end

  context 'when the site is using a paid tier and billing is valid' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:billing, status: Billing::VALID, site:, user: site.owner.user)

      site.plan.update(tier: 3)
    end

    subject do
      variables = {
        site_id: site.id
      }
      graphql_request(site_plan_query, variables, user)
    end

    it 'returns the default plan for this tier' do
      response = subject['data']['site']['plan']
      expect(response).to eq(
        'tier' => 3,
        'name' => 'Business',
        'exceeded' => false,
        'invalid' => false,
        'maxMonthlyRecordings' => 100000,
        'dataStorageMonths' => 12,
        'responseTimeHours' => 24,
        'support' => [
          'Email',
          'Chat'
        ]
      )
    end
  end

  context 'when the site is using a paid tier and billing is invalid' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:billing, status: Billing::INVALID, site:, user: site.owner.user)

      site.plan.update(tier: 2)
    end

    subject do
      variables = {
        site_id: site.id
      }
      graphql_request(site_plan_query, variables, user)
    end

    it 'returns the default plan for this tier' do
      response = subject['data']['site']['plan']
      expect(response).to eq(
        'tier' => 2,
        'name' => 'Plus',
        'exceeded' => false,
        'invalid' => true,
        'maxMonthlyRecordings' => 50000,
        'dataStorageMonths' => 12,
        'responseTimeHours' => 24,
        'support' => [
          'Email'
        ]
      )
    end
  end

  context 'when the site is using a paid tier and billing is valid but exceeded' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:billing, status: Billing::VALID, site:, user: site.owner.user)

      allow_any_instance_of(Plan).to receive(:all_recordings_count).and_return(50001)
      allow_any_instance_of(Plan).to receive(:max_monthly_recordings).and_return(50000)

      site.plan.update(tier: 2)
    end

    subject do
      variables = {
        site_id: site.id
      }
      graphql_request(site_plan_query, variables, user)
    end

    it 'returns the default plan for this tier' do
      response = subject['data']['site']['plan']
      expect(response).to eq(
        'tier' => 2,
        'name' => 'Plus',
        'exceeded' => true,
        'invalid' => false,
        'maxMonthlyRecordings' => 50000,
        'dataStorageMonths' => 12,
        'responseTimeHours' => 24,
        'support' => [
          'Email'
        ]
      )
    end
  end

  context 'when the site is using a paid tier and billing is invalid and exceeded' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:billing, status: Billing::INVALID, site:, user: site.owner.user)

      allow_any_instance_of(Plan).to receive(:all_recordings_count).and_return(50001)
      allow_any_instance_of(Plan).to receive(:max_monthly_recordings).and_return(50000)

      site.plan.update(tier: 2)
    end

    subject do
      variables = {
        site_id: site.id
      }
      graphql_request(site_plan_query, variables, user)
    end

    it 'returns the default plan for this tier' do
      response = subject['data']['site']['plan']
      expect(response).to eq(
        'tier' => 2,
        'name' => 'Plus',
        'exceeded' => true,
        'invalid' => true,
        'maxMonthlyRecordings' => 50000,
        'dataStorageMonths' => 12,
        'responseTimeHours' => 24,
        'support' => [
          'Email'
        ]
      )
    end
  end

  context 'when the site is on an enterprise plan and has no overrides' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:billing, status: Billing::VALID, site:, user: site.owner.user)

      site.plan.update(tier: 5)
    end

    subject do
      variables = {
        site_id: site.id
      }
      graphql_request(site_plan_query, variables, user)
    end

    it 'returns the default plan for this tier' do
      response = subject['data']['site']['plan']
      expect(response).to eq(
        'tier' => 5,
        'name' => 'Enterprise Tier 1',
        'exceeded' => false,
        'invalid' => false,
        'maxMonthlyRecordings' => 250000,
        'dataStorageMonths' => -1,
        'responseTimeHours' => 0,
        'support' => [
          'Email',
          'Chat',
          'Phone'
        ]
      )
    end
  end

  context 'when the site is on an enterprise plan and has overrides' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:billing, status: Billing::VALID, site:, user: site.owner.user)

      site.plan.update(
        tier: 5,
        max_monthly_recordings: 500000,
        data_storage_months: 36,
        support: ['Email', 'Phone']
      )
    end

    subject do
      variables = {
        site_id: site.id
      }
      graphql_request(site_plan_query, variables, user)
    end

    it 'returns the default plan for this tier' do
      response = subject['data']['site']['plan']
      expect(response).to eq(
        'tier' => 5,
        'name' => 'Enterprise Tier 1',
        'exceeded' => false,
        'invalid' => false,
        'maxMonthlyRecordings' => 500000,
        'dataStorageMonths' => 36,
        'responseTimeHours' => 0,
        'support' => [
          'Email',
          'Phone'
        ]
      )
    end
  end
end
