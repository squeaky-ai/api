# frozen_string_literal: true

require 'rails_helper'

analytics_browser_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        browsers {
          name
          count
        }
      }
    }
  }
GRAPHQL

RSpec.describe Types::AnalyticsBrowserExtension, type: :request do
  context 'when there are no recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_browser_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['analytics']
      expect(response['browsers']).to eq []
    end
  end

  context 'when there are some recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ deleted: true, created_at: Date.new(2021, 8, 7), useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:91.0) Gecko/20100101 Firefox/91.0' }, site: site)
      create_recording({ deleted: true, created_at: Date.new(2021, 8, 6), useragent: '"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15"' }, site: site)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_browser_query, variables, user)
    end

    it 'returns the browser counts' do
      response = subject['data']['site']['analytics']
      expect(response['browsers']).to eq(
        [
          {
            'name' => 'Safari',
            'count' => 1
          },
          {
            'name' => 'Firefox',
            'count' => 1
          }
        ]
      )
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ deleted: true, created_at: Date.new(2021, 8, 7), useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:91.0) Gecko/20100101 Firefox/91.0' }, site: site)
      create_recording({ deleted: true, created_at: Date.new(2021, 8, 6), useragent: '"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15"' }, site: site)
      create_recording({ deleted: true, created_at: Date.new(2021, 7, 6), useragent: '"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15"' }, site: site)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_browser_query, variables, user)
    end

    it 'returns the browser counts' do
      response = subject['data']['site']['analytics']
      expect(response['browsers']).to eq(
        [
          {
            'name' => 'Safari',
            'count' => 1
          },
          {
            'name' => 'Firefox',
            'count' => 1
          }
        ]
      )
    end
  end
end
