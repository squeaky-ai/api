# frozen_string_literal: true

require 'rails_helper'

site_plan_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      id
      plan {
        planId
        free
        enterprise
        deprecated
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
        'planId' => '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f',
        'name' => 'Free',
        'free' => true,
        'enterprise' => false,
        'deprecated' => false,
        'exceeded' => false,
        'invalid' => false,
        'maxMonthlyRecordings' => 1000,
        'dataStorageMonths' => 3,
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

      site.plan.update(plan_id: 'b2054935-4fdf-45d0-929b-853cfe8d4a1c')
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
        'planId' => 'b2054935-4fdf-45d0-929b-853cfe8d4a1c',
        'free' => false,
        'enterprise' => false,
        'deprecated' => false,
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

      site.plan.update(plan_id: 'f20c93ec-172f-46c6-914e-6a00dff3ae5f')
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
        'planId' => 'f20c93ec-172f-46c6-914e-6a00dff3ae5f',
        'free' => false,
        'enterprise' => false,
        'deprecated' => true,
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

      site.plan.update(plan_id: 'f20c93ec-172f-46c6-914e-6a00dff3ae5f')
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
        'planId' => 'f20c93ec-172f-46c6-914e-6a00dff3ae5f',
        'free' => false,
        'enterprise' => false,
        'deprecated' => true,
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

      site.plan.update(plan_id: 'f20c93ec-172f-46c6-914e-6a00dff3ae5f')
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
        'planId' => 'f20c93ec-172f-46c6-914e-6a00dff3ae5f',
        'free' => false,
        'enterprise' => false,
        'deprecated' => true,
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

      site.plan.update(plan_id: 'eacfcc46-82ba-4994-9d01-19696c4e374b')
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
        'planId' => 'eacfcc46-82ba-4994-9d01-19696c4e374b',
        'free' => false,
        'enterprise' => true,
        'deprecated' => false,
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
        plan_id: 'eacfcc46-82ba-4994-9d01-19696c4e374b',
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
        'planId' => 'eacfcc46-82ba-4994-9d01-19696c4e374b',
        'free' => false,
        'enterprise' => true,
        'deprecated' => false,
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
