# frozen_string_literal: true

require 'rails_helper'

analytics_browser_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
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
GRAPHQL

RSpec.describe Resolvers::Analytics::Browsers, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_browser_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['analytics']['browsers']
      expect(response['items']).to eq []
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 7).to_i * 1000,
          browser: 'Firefox'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 6).to_i * 1000,
          browser: 'Safari'
        }
      ]
    end

    before do
      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_browser_query, variables, user)
    end

    it 'returns the browser counts' do
      response = subject['data']['site']['analytics']['browsers']
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

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 7).to_i * 1000,
          browser: 'Firefox'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 6).to_i * 1000,
          browser: 'Safari'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 6).to_i * 1000,
          browser: 'Safari'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 7, 6).to_i * 1000,
          browser: 'Safari'
        }
      ]
    end

    before do
      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_browser_query, variables, user)
    end

    it 'returns the browser counts' do
      response = subject['data']['site']['analytics']['browsers']
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
