# frozen_string_literal: true

require 'rails_helper'

site_utm_campaigns_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      utmCampaigns
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::UtmCampaigns, type: :request do
  context 'when there are no campaigns' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_utm_campaigns_query, variables, user)
    end

    it 'returns no campaigns' do
      response = subject['data']['site']['utmCampaigns']
      expect(response).to eq []
    end
  end

  context 'when there are some campaigns' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_campaign: 'campaign_1'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_campaign: 'campaign_2'
        }
      ]
    end

    before do
      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_utm_campaigns_query, variables, user)
    end

    it 'returns the campaigns' do
      response = subject['data']['site']['utmCampaigns']
      expect(response).to eq ['campaign_1', 'campaign_2']
    end
  end

  context 'when there are some duplicate campaigns' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_campaign: 'campaign_1'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_campaign: 'campaign_2'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_campaign: 'campaign_1'
        }
      ]
    end

    before do
      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_utm_campaigns_query, variables, user)
    end

    it 'returns them deduped' do
      response = subject['data']['site']['utmCampaigns']
      expect(response).to eq ['campaign_1', 'campaign_2']
    end
  end
end
