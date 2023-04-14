# typed: false
# frozen_string_literal: true

require 'rails_helper'

site_utm_mediums_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      utmMediums
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::UtmMediums, type: :request do
  context 'when there are no mediums' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_utm_mediums_query, variables, user)
    end

    it 'returns no mediums' do
      response = subject['data']['site']['utmMediums']
      expect(response).to eq []
    end
  end

  context 'when there are some mediums' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_medium: 'medium_1'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_medium: 'medium_2'
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
      graphql_request(site_utm_mediums_query, variables, user)
    end

    it 'returns the mediums' do
      response = subject['data']['site']['utmMediums']
      expect(response).to eq ['medium_1', 'medium_2']
    end
  end

  context 'when there are some duplicate mediums' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_medium: 'medium_1'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_medium: 'medium_2'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_medium: 'medium_1'
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
      graphql_request(site_utm_mediums_query, variables, user)
    end

    it 'returns them deduped' do
      response = subject['data']['site']['utmMediums']
      expect(response).to eq ['medium_1', 'medium_2']
    end
  end
end
