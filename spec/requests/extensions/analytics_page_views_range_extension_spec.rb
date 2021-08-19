# frozen_string_literal: true

require 'rails_helper'

analytics_page_views_range_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        pageViewsRange {
          date
          pageViewCount
        }
      }
    }
  }
GRAPHQL

RSpec.describe Types::AnalyticsPageViewsRangeExtension, type: :request do
  context 'when there are no recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_page_views_range_query, variables, user)
    end

    it 'returns 0' do
      response = subject['data']['site']['analytics']
      expect(response['pageViewsRange']).to eq []
    end
  end

  context 'when there are some recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ created_at: Date.new(2021, 8, 7), page_views: ['/'] }, site: site, visitor: create_visitor)
      create_recording({ created_at: Date.new(2021, 8, 6), page_views: ['/', '/test'] }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_page_views_range_query, variables, user)
    end

    it 'returns the page views count' do
      response = subject['data']['site']['analytics']
      expect(response['pageViewsRange']).to eq(
        [
          {
            'date' => '2021-08-06T00:00:00Z',
            'pageViewCount' => 2
          },
          {
            'date' => '2021-08-07T00:00:00Z',
            'pageViewCount' => 1
          }
        ]
      )
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ created_at: Date.new(2021, 8, 7), page_views: ['/'] }, site: site, visitor: create_visitor)
      create_recording({ created_at: Date.new(2021, 8, 6), page_views: ['/', '/test'] }, site: site, visitor: create_visitor)
      create_recording({ created_at: Date.new(2021, 7, 6), page_views: ['/contact'] }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_page_views_range_query, variables, user)
    end

    it 'returns the page views count' do
      response = subject['data']['site']['analytics']
      expect(response['pageViewsRange']).to eq(
        [
          {
            'date' => '2021-08-06T00:00:00Z',
            'pageViewCount' => 2
          },
          {
            'date' => '2021-08-07T00:00:00Z',
            'pageViewCount' => 1
          }
        ]
      )
    end
  end
end
  