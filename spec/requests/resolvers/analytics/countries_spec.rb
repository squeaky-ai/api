# frozen_string_literal: true

require 'rails_helper'

analytics_countries_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        countries {
          name
          count
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::Countries, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_countries_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['analytics']
      expect(response['countries']).to eq []
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, country_code: 'GB', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, country_code: 'SE', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, country_code: 'GB', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, country_code: 'FR', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, country_code: 'ZZ', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, country_code: 'GB', site: site)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_countries_query, variables, user)
    end

    it 'returns the countries counts' do
      response = subject['data']['site']['analytics']
      expect(response['countries']).to match_array(
        [
          {
            'name' => 'United Kingdom',
            'count' => 3
          },
          {
            'name' => 'Sweden',
            'count' => 1
          },
          {
            'name' => 'France',
            'count' => 1
          },
          {
            'name' => 'Unknown',
            'count' => 1
          }
        ]
      )
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, country_code: 'GB', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, country_code: 'SE', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, country_code: 'GB', site: site)
      create(:recording, disconnected_at: Time.new(2021, 7, 6).to_i * 1000, country_code: 'FR', site: site)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_countries_query, variables, user)
    end

    it 'returns the countries counts' do
      response = subject['data']['site']['analytics']
      expect(response['countries']).to match_array(
        [
          {
            'name' => 'United Kingdom',
            'count' => 2
          },
          {
            'name' => 'Sweden',
            'count' => 1
          }
        ]
      )
    end
  end
end
