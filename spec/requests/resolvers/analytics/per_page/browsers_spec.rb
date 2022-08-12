# frozen_string_literal: true

require 'rails_helper'

analytics_per_page_browser_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!, $page: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        perPage(page: $page) {
          browsers {
            items {
              browser
              count
              percentage
            }
            pagination {
              pageSize
              total
            }
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::PerPage::Browsers, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        site_id: site.id,
        from_date: '2021-08-01',
        to_date: '2021-08-08',
        page: '/'
      }
      graphql_request(analytics_per_page_browser_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['analytics']['perPage']['browsers']
      expect(response['items']).to eq []
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, browser: 'Firefox', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, browser: 'Safari', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, browser: 'Chrome', site: site, page_urls: ['/test'])
    end

    subject do
      variables = {
        site_id: site.id,
        from_date: '2021-08-01',
        to_date: '2021-08-08',
        page: '/'
      }
      graphql_request(analytics_per_page_browser_query, variables, user)
    end

    it 'returns the browser counts' do
      response = subject['data']['site']['analytics']['perPage']['browsers']
      expect(response['items']).to match_array(
        [
          {
            'browser' => 'Safari',
            'percentage' => 50,
            'count' => 1
          },
          {
            'browser' => 'Firefox',
            'percentage' => 50,
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
      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, browser: 'Firefox', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, browser: 'Safari', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, browser: 'Safari', site: site)
      create(:recording, disconnected_at: Time.new(2021, 7, 6).to_i * 1000, browser: 'Safari', site: site)
    end

    subject do
      variables = {
        site_id: site.id,
        from_date: '2021-08-01',
        to_date: '2021-08-08',
        page: '/'
      }
      graphql_request(analytics_per_page_browser_query, variables, user)
    end

    it 'returns the browser counts' do
      response = subject['data']['site']['analytics']['perPage']['browsers']
      expect(response['items']).to match_array(
        [
          {
            'browser' => 'Safari',
            'percentage' => 66,
            'count' => 2
          },
          {
            'browser' => 'Firefox',
            'percentage' => 33,
            'count' => 1
          }
        ]
      )
    end
  end
end
