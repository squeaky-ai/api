# frozen_string_literal: true

require 'rails_helper'

analytics_pages_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        pages {
          items {
            url
            viewCount
            viewPercentage
            exitRatePercentage
            bounceRatePercentage
            averageDuration
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
      page_1 = create(:page, url: '/', entered_at: 1656444914353, exited_at: 1656444926825, bounced_on: true, exited_on: true)
      page_2 = create(:page, url: '/', entered_at: 1656444914353, exited_at: 1656444926825, bounced_on: false, exited_on: false)
      page_3 = create(:page, url: '/test', entered_at: 1656444914353, exited_at: 1656444926825, bounced_on: false, exited_on: true)

      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, site: site, pages: [page_1])
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, site: site, pages: [page_2, page_3])
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
            'averageDuration' => 10731,
            'bounceRatePercentage' => 25.0,
            'exitRatePercentage' => 25.0,
            'url' => '/',
            'viewCount' => 4,
            'viewPercentage' => 80.00
          },
          {
            'averageDuration' => 12472,
            'bounceRatePercentage' => 0.0,
            'exitRatePercentage' => 100.0,
            'url' => '/test',
            'viewCount' => 1,
            'viewPercentage' => 20.0
         }
        ]
      )
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      page_1 = create(:page, url: '/', entered_at: 1656444914353, exited_at: 1656444926825, bounced_on: true, exited_on: true)
      page_2 = create(:page, url: '/', entered_at: 1656444914353, exited_at: 1656444926825, bounced_on: false, exited_on: false)
      page_3 = create(:page, url: '/test', entered_at: 1656444914353, exited_at: 1656444926825, bounced_on: false, exited_on: true)

      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, site: site, pages: [page_1])
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, site: site, pages: [page_2, page_3])
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
            'averageDuration' => 10731,
            'bounceRatePercentage' => 25.0,
            'exitRatePercentage' => 25.0,
            'url' => '/',
            'viewCount' => 4,
            'viewPercentage' => 80.0
          },
          {
            'averageDuration' => 12472,
            'bounceRatePercentage' => 0.0,
            'exitRatePercentage' => 100.0,
            'url' => '/test',
            'viewCount' => 1,
            'viewPercentage' => 20.0
          }
        ]
      )
    end
  end
end
