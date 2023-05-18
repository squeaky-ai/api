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

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          activity_duration: 1000,
          entered_at: 1656444914353, 
          exited_at: 1656444926825, 
          bounced_on: true, 
          exited_on: true
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          activity_duration: 2000,
          entered_at: 1656444914353, 
          exited_at: 1656444926825, 
          bounced_on: false, 
          exited_on: false
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test', 
          activity_duration: 3500,
          entered_at: 1656444914353, 
          exited_at: 1656444926825, 
          bounced_on: false, 
          exited_on: true
        }
      ]
    end

    before do
      ClickHouse::PageEvent.insert do |buffer|
        pages.each { |page| buffer << page }
      end
    end

    subject do
      variables = { site_id: site.id, from_date: '2022-06-23', to_date: '2022-06-30' }
      graphql_request(analytics_pages_query, variables, user)
    end

    it 'returns the pages' do
      response = subject['data']['site']['analytics']['pages']
      expect(response['items']).to eq(
        [
          {
            'averageDuration' => 1500,
            'bounceRatePercentage' => 50.0,
            'exitRatePercentage' => 50.0,
            'url' => '/',
            'viewCount' => 2,
            'viewPercentage' => 66.67
          },
          {
            'averageDuration' => 3500,
            'bounceRatePercentage' => 0.0,
            'exitRatePercentage' => 100.0,
            'url' => '/test',
            'viewCount' => 1,
            'viewPercentage' => 33.33
         }
        ]
      )
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          activity_duration: 1000,
          entered_at: 1656444914353, 
          exited_at: 1656444926825,
          bounced_on: true,
          exited_on: true
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          activity_duration: 2000,
          entered_at: 1656444914353,
          exited_at: 1656444926825, 
          bounced_on: false, 
          exited_on: false
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test', 
          activity_duration: 3500,
          entered_at: 1656444914353, 
          exited_at: 1656444926825, 
          bounced_on: false, 
          exited_on: true
        }
      ]
    end

    before do
      ClickHouse::PageEvent.insert do |buffer|
        pages.each { |page| buffer << page }
      end
    end

    subject do
      variables = { site_id: site.id, from_date: '2022-06-23', to_date: '2022-06-30' }
      graphql_request(analytics_pages_query, variables, user)
    end

    it 'returns the pages' do
      response = subject['data']['site']['analytics']['pages']
      expect(response['items']).to eq(
        [
          {
            'averageDuration' => 1500,
            'bounceRatePercentage' => 50.0,
            'exitRatePercentage' => 50.0,
            'url' => '/',
            'viewCount' => 2,
            'viewPercentage' => 66.67
          },
          {
            'averageDuration' => 3500,
            'bounceRatePercentage' => 0.0,
            'exitRatePercentage' => 100.0,
            'url' => '/test',
            'viewCount' => 1,
            'viewPercentage' => 33.33
          }
        ]
      )
    end
  end
end
