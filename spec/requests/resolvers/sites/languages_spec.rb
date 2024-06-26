# frozen_string_literal: true

require 'rails_helper'

site_languages_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      languages
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::Languages, type: :request, truncate_click_house: true do
  context 'when there are no languages' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_languages_query, variables, user)
    end

    it 'returns no languages' do
      response = subject['data']['site']['languages']
      expect(response).to eq []
    end
  end

  context 'when there are some languages' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          locale: 'en-GB'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          locale: 'sv-SE'
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
      graphql_request(site_languages_query, variables, user)
    end

    it 'returns the languages' do
      response = subject['data']['site']['languages']
      expect(response).to match_array ['English (GB)', 'Swedish (SE)']
    end
  end

  context 'when there are some duplicate languages' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          locale: 'en-GB'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          locale: 'en-GB'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          locale: 'sv-SE'
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
      graphql_request(site_languages_query, variables, user)
    end

    it 'returns them deduped' do
      response = subject['data']['site']['languages']
      expect(response).to match_array ['English (GB)', 'Swedish (SE)']
    end
  end
end
