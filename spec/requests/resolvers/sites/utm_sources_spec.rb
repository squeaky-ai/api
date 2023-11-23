# frozen_string_literal: true

require 'rails_helper'

site_utm_sources_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      utmSources
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::UtmSources, type: :request do
  context 'when there are no sources' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_utm_sources_query, variables, user)
    end

    it 'returns no sources' do
      response = subject['data']['site']['utmSources']
      expect(response).to eq []
    end
  end

  context 'when there are some sources' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_source: 'source_1'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_source: 'source_2'
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
      graphql_request(site_utm_sources_query, variables, user)
    end

    it 'returns the sources' do
      response = subject['data']['site']['utmSources']
      expect(response).to eq %w[source_1 source_2]
    end
  end

  context 'when there are some duplicate sources' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_source: 'source_1'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_source: 'source_2'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_source: 'source_1'
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
      graphql_request(site_utm_sources_query, variables, user)
    end

    it 'returns them deduped' do
      response = subject['data']['site']['utmSources']
      expect(response).to eq %w[source_1 source_2]
    end
  end
end
