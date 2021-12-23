# frozen_string_literal: true

require 'rails_helper'

analytics_language_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        languages {
          name
          count
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::Languages, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_language_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['analytics']
      expect(response['languages']).to eq []
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, locale: 'en-gb', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, locale: 'en-gb', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, locale: 'sv-se', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, locale: 'zz-zz', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, locale: 'xx-aa', site: site)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_language_query, variables, user)
    end

    it 'returns the languages counts' do
      response = subject['data']['site']['analytics']
      expect(response['languages']).to eq(
        [
          {
            'name' => 'English (GB)',
            'count' => 2
          },
          {
            'name' => 'Swedish (SE)',
            'count' => 1
          },
          {
            'name' => 'Unknown',
            'count' => 2
          }
        ]
      )
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, locale: 'en-gb', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, locale: 'en-gb', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, locale: 'sv-se', site: site)
      create(:recording, disconnected_at: Time.new(2021, 7, 6).to_i * 1000, locale: 'sv-se', site: site)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_language_query, variables, user)
    end

    it 'returns the languages counts' do
      response = subject['data']['site']['analytics']
      expect(response['languages']).to eq(
        [
          {
            'name' => 'English (GB)',
            'count' => 2
          },
          {
            'name' => 'Swedish (SE)',
            'count' => 1
          }
        ]
      )
    end
  end
end
