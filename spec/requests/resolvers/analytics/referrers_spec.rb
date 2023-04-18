# frozen_string_literal: true

require 'rails_helper'

analytics_referrers_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        referrers {
          items {
            referrer
            count
            percentage
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::Referrers, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_referrers_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['analytics']['referrers']
      expect(response['items']).to eq []
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:visitor_1) { create(:visitor) }
    let(:visitor_2) { create(:visitor) }
    let(:visitor_3) { create(:visitor) }
    let(:visitor_4) { create(:visitor) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          referrer: 'http://google.com',
          disconnected_at: Time.new(2021, 8, 7).to_i * 1000,
          visitor_id: visitor_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          referrer: 'http://google.com',
          disconnected_at: Time.new(2021, 8, 7).to_i * 1000,
          visitor_id: visitor_2.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          referrer: nil,
          disconnected_at: Time.new(2021, 8, 7).to_i * 1000,
          visitor_id: visitor_3.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          referrer: 'http://facebook.com',
          disconnected_at: Time.new(2021, 8, 6).to_i * 1000,
          visitor_id: visitor_4.id
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
      graphql_request(analytics_referrers_query, variables, user)
    end

    it 'returns the referrers' do
      response = subject['data']['site']['analytics']['referrers']
      expect(response['items']).to match_array([
        {
          'referrer' => 'http://google.com',
          'percentage' => 50,
          'count' => 2
        },
        {
          'referrer' => 'http://facebook.com',
          'percentage' => 25,
          'count' => 1
        },
        {
          'referrer' => 'Direct',
          'percentage' => 25,
          'count' => 1
        }
      ])
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:visitor_1) { create(:visitor) }
    let(:visitor_2) { create(:visitor) }
    let(:visitor_3) { create(:visitor) }
    let(:visitor_4) { create(:visitor) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          referrer: 'http://google.com', 
          disconnected_at: Time.new(2021, 8, 7).to_i * 1000,
          visitor_id: visitor_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          referrer: nil, 
          disconnected_at: Time.new(2021, 8, 7).to_i * 1000,
          visitor_id: visitor_2.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          referrer: 'http://facebook.com', 
          disconnected_at: Time.new(2021, 8, 6).to_i * 1000,
          visitor_id: visitor_3.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          referrer: 'http://facebook.com', 
          disconnected_at: Time.new(2021, 7, 6).to_i * 1000,
          visitor_id: visitor_4.id
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
      graphql_request(analytics_referrers_query, variables, user)
    end

    it 'returns the referrers' do
      response = subject['data']['site']['analytics']['referrers']
      expect(response['items']).to match_array([
        {
          'referrer' => 'http://google.com',
          'percentage' => 33.33,
          'count' => 1
        },
        {
          'referrer' => 'http://facebook.com',
          'percentage' => 33.33,
          'count' => 1
        },
        {
          'referrer' => 'Direct',
          'percentage' => 33.33,
          'count' => 1
        }
      ])
    end
  end
end
