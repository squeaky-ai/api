# frozen_string_literal: true

require 'rails_helper'

analytics_page_views_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        pageViews {
          groupType
          groupRange
          items {
            dateKey
            totalCount
            uniqueCount
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::PageViews, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_page_views_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['analytics']
      expect(response['pageViews']).to eq(
        'groupType' => 'daily',
        'groupRange' => 7,
        'items' => []
      )
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      visitor = create(:visitor)

      recording_1 = create(:recording, site: site, visitor: visitor)
      create(:page, url: '/', exited_at: Time.new(2021, 8, 7).to_i * 1000, recording: recording_1)
      create(:page, url: '/test', exited_at: Time.new(2021, 8, 7).to_i * 1000, recording: recording_1)

      recording_2 = create(:recording, site: site, visitor: visitor)
      create(:page, url: '/', exited_at: Time.new(2021, 8, 6).to_i * 1000, recording: recording_2)

      recording_3 = create(:recording, site: site, visitor: visitor)
      create(:page, url: '/test', exited_at: Time.new(2021, 8, 5).to_i * 1000, recording: recording_3)
      create(:page, url: '/test', exited_at: Time.new(2021, 8, 5).to_i * 1000, recording: recording_3)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_page_views_query, variables, user)
    end

    it 'returns the page views' do
      response = subject['data']['site']['analytics']

      expect(response['pageViews']).to eq(
        'groupType' => 'daily',
        'groupRange' => 7,
        'items' =>  [
          {
            'dateKey' => '020', 
            'totalCount' => 5, 
            'uniqueCount' => 2
          }
        ]
      )
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      visitor = create(:visitor)

      recording_1 = create(:recording, site: site, visitor: visitor)
      create(:page, url: '/', exited_at: Time.new(2021, 8, 7).to_i * 1000, recording: recording_1)
      create(:page, url: '/test', exited_at: Time.new(2021, 8, 7).to_i * 1000, recording: recording_1)

      recording_2 = create(:recording, site: site, visitor: visitor)
      create(:page, url: '/', exited_at: Time.new(2021, 8, 6).to_i * 1000, recording: recording_2)
      create(:page, url: '/test', exited_at: Time.new(2021, 8, 6).to_i * 1000, recording: recording_2)
      create(:page, url: '/', exited_at: Time.new(2021, 8, 6).to_i * 1000, recording: recording_2)

      recording_3 = create(:recording, site: site, visitor: visitor)
      create(:page, url: '/test', exited_at: Time.new(2021, 8, 5).to_i * 1000, recording: recording_3)

      recording_4 = create(:recording, site: site, visitor: visitor)
      create(:page, url: '/test', exited_at: Time.new(2021, 7, 5).to_i * 1000, recording: recording_4)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_page_views_query, variables, user)
    end

    it 'returns the page views' do
      response = subject['data']['site']['analytics']
      
      expect(response['pageViews']).to eq(
        'groupType' => 'daily',
        'groupRange' => 7,
        'items' =>  [
          {
            'dateKey' => '020', 
            'totalCount' => 6, 
            'uniqueCount' => 2
          }
        ]
      )
    end
  end
end
