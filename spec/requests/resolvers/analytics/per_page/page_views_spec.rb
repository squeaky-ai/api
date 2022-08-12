# frozen_string_literal: true

require 'rails_helper'

analytics_per_page_page_views_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!, $page: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        perPage(page: $page) {
          pageViews {
            groupType
            groupRange
            total
            trend
            items {
              dateKey
              count
            }
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::PerPage::PageViews, type: :request do
  context 'when there are no pages' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        site_id: site.id,
        from_date: '2021-08-01',
        to_date: '2021-08-08',
        page: '/'
      }
      graphql_request(analytics_per_page_page_views_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['analytics']['perPage']
      expect(response['pageViews']).to eq(
        'groupType' => 'daily',
        'groupRange' => 7,
        'total' => 0,
        'trend' => 0,
        'items' => []
      )
    end
  end

  context 'when there are some pages' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      visitor = create(:visitor)

      create(:page, url: '/', exited_at: Time.new(2021, 8, 7).to_i * 1000, site_id: site.id)
      create(:page, url: '/', exited_at: Time.new(2021, 8, 6).to_i * 1000, site_id: site.id)
      create(:page, url: '/test', exited_at: Time.new(2021, 8, 5).to_i * 1000, site_id: site.id)
      create(:page, url: '/test', exited_at: Time.new(2021, 8, 5).to_i * 1000, site_id: site.id)
      create(:page, url: '/test', exited_at: Time.new(2021, 8, 7).to_i * 1000, site_id: site.id)
    end

    subject do
      variables = {
        site_id: site.id,
        from_date: '2021-08-01',
        to_date: '2021-08-08',
        page: '/'
      }
      graphql_request(analytics_per_page_page_views_query, variables, user)
    end

    it 'returns the page views' do
      response = subject['data']['site']['analytics']['perPage']

      expect(response['pageViews']).to eq(
        'groupType' => 'daily',
        'groupRange' => 7,
        'total' => 2,
        'trend' => 2,
        'items' =>  [
          {
            'count' => 1,
            'dateKey' => '217'
          },
          {
            'count' => 1,
            'dateKey' => '218'
          }
        ]
      )
    end
  end

  context 'when some of the pages are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      visitor = create(:visitor)

      create(:page, url: '/', exited_at: Time.new(2021, 8, 6).to_i * 1000, site_id: site.id)
      create(:page, url: '/', exited_at: Time.new(2021, 8, 6).to_i * 1000, site_id: site.id)
      create(:page, url: '/', exited_at: Time.new(2021, 8, 7).to_i * 1000, site_id: site.id)
      create(:page, url: '/test', exited_at: Time.new(2021, 8, 5).to_i * 1000, site_id: site.id)
      create(:page, url: '/test', exited_at: Time.new(2021, 8, 6).to_i * 1000, site_id: site.id)
      create(:page, url: '/test', exited_at: Time.new(2021, 8, 7).to_i * 1000, site_id: site.id)
      create(:page, url: '/test', exited_at: Time.new(2021, 7, 5).to_i * 1000, site_id: site.id)
    end

    subject do
      variables = {
        site_id: site.id,
        from_date: '2021-08-01',
        to_date: '2021-08-08',
        page: '/'
      }
      graphql_request(analytics_per_page_page_views_query, variables, user)
    end

    it 'returns the page views' do
      response = subject['data']['site']['analytics']['perPage']
      
      expect(response['pageViews']).to eq(
        'groupType' => 'daily',
        'groupRange' => 7,
        'total' => 3,
        'trend' => 3,
        'items' =>  [
          {
            'count' => 2,
            'dateKey' => '217'
          }, 
          {
            'count' => 1,
            'dateKey' => '218'
          }
        ]
      )
    end
  end
end
