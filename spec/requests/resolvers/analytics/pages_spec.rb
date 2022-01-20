# frozen_string_literal: true

require 'rails_helper'

analytics_pages_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        pages {
          items {
            path
            count
            avg
            percentage
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::Pages, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_pages_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['analytics']['pages']
      expect(response['items']).to eq []
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, site: site, page_urls: ['/'])
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, site: site, page_urls: ['/', '/test'])
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_pages_query, variables, user)
    end

    it 'returns the pages' do
      response = subject['data']['site']['analytics']['pages']
      expect(response['items']).to eq(
        [
          {
            'path' => '/',
            'avg' => 8990,
            'percentage' => 66,
            'count' => 2
          },
          {
            'path' => '/test',
            'avg' => 8990,
            'percentage' => 33,
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
      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, site: site, page_urls: ['/'])
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, site: site, page_urls: ['/', '/test'])
      create(:recording, disconnected_at: Time.new(2021, 7, 6).to_i * 1000, site: site, page_urls: ['/contact'])
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_pages_query, variables, user)
    end

    it 'returns the pages' do
      response = subject['data']['site']['analytics']['pages']
      expect(response['items']).to eq(
        [
          {
            'path' => '/',
            'avg' => 8990,
            'percentage' => 66,
            'count' => 2
          },
          {
            'path' => '/test',
            'avg' => 8990,
            'percentage' => 33,
            'count' => 1
          }
        ]
      )
    end
  end
end
