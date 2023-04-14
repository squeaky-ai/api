# typed: false
# frozen_string_literal: true

require 'rails_helper'

site_countries_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      countries {
        name
        code
        count
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::Browsers, type: :request do
  context 'when there are no country codes' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_countries_query, variables, user)
    end

    it 'returns no country codes' do
      response = subject['data']['site']['countries']
      expect(response).to eq []
    end
  end

  context 'when there are some country codes' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          country_code: 'GB'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          country_code: 'SE'
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
      graphql_request(site_countries_query, variables, user)
    end

    it 'returns the country codes' do
      response = subject['data']['site']['countries']
      expect(response).to match_array(
        [
          {
            'code' => 'GB',
            'name' => 'United Kingdom',
            'count' => 1
          },
          {
            'code' => 'SE',
            'name' => 'Sweden',
            'count' => 1
          }
        ]
      )
    end
  end

  context 'when there are some duplicate country codes' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          country_code: 'GB'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          country_code: 'SE'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          country_code: 'GB'
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
      graphql_request(site_countries_query, variables, user)
    end

    it 'returns the country codes' do
      response = subject['data']['site']['countries']
      expect(response).to match_array(
        [
          {
            'code' => 'GB',
            'name' => 'United Kingdom',
            'count' => 2
          },
          {
            'code' => 'SE',
            'name' => 'Sweden',
            'count' => 1
          }
        ]
      )
    end
  end
end
