# frozen_string_literal: true

require 'rails_helper'

analytics_page_views_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
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
GRAPHQL

RSpec.describe Resolvers::Analytics::PageViews, type: :request do
  context 'when there are no pages' do
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
        'total' => 0,
        'trend' => 0,
        'items' => []
      )
    end
  end

  context 'when there are some pages' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:visitor) { create(:visitor) }

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          exited_at: Time.new(2021, 8, 7).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          exited_at: Time.new(2021, 8, 6).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test',
          exited_at: Time.new(2021, 8, 5).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test',
          exited_at: Time.new(2021, 8, 5).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test',
          exited_at: Time.new(2021, 8, 7).to_i * 1000
        }
      ]
    end

    before do
      ClickHouse::PageEvent.insert do |buffer|
        pages.each { |page| buffer << page }
      end
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
        'total' => 5,
        'trend' => 5,
        'items' => [
          {
            'count' => 2,
            'dateKey' => '216'
          },
          {
            'count' => 1,
            'dateKey' => '217'
          },
          {
            'count' => 2,
            'dateKey' => '218'
          }
        ]
      )
    end
  end

  context 'when some of the pages are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:visitor) { create(:visitor) }

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          exited_at: Time.new(2021, 8, 6).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          exited_at: Time.new(2021, 8, 6).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          exited_at: Time.new(2021, 8, 7).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test',
          exited_at: Time.new(2021, 8, 5).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test',
          exited_at: Time.new(2021, 8, 6).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test',
          exited_at: Time.new(2021, 8, 7).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test',
          exited_at: Time.new(2021, 7, 5).to_i * 1000
        }
      ]
    end

    before do
      ClickHouse::PageEvent.insert do |buffer|
        pages.each { |page| buffer << page }
      end
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
        'total' => 6,
        'trend' => 6,
        'items' => [
          {
            'count' => 1,
            'dateKey' => '216'
          },
          {
            'count' => 3,
            'dateKey' => '217'
          },
          {
            'count' => 2,
            'dateKey' => '218'
          }
        ]
      )
    end
  end
end
