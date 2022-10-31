# frozen_string_literal: true

require 'rails_helper'

analytics_dimensions_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        dimensions {
          deviceX
          count
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::Dimensions, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_dimensions_query, variables, user)
    end

    it 'returns 0 for all the stats' do
      response = subject['data']['site']['analytics']
      expect(response['dimensions']).to eq([])
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
          device_x: 1920
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 6).to_i * 1000,
          device_x: 2560
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
      graphql_request(analytics_dimensions_query, variables, user)
    end

    it 'returns the dimensions stats' do
      response = subject['data']['site']['analytics']
      expect(response['dimensions']).to match_array(
        [
          {
            'deviceX' => 1920,
            'count' => 1
          },
          {
            'deviceX' => 2560,
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
          device_x: 1920
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 6).to_i * 1000,
          device_x: 2560
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 7, 6).to_i * 1000,
          device_x: 3840
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
      graphql_request(analytics_dimensions_query, variables, user)
    end

    it 'returns the dimensions stats' do
      response = subject['data']['site']['analytics']
      expect(response['dimensions']).to match_array(
        [
          {
            'deviceX' => 1920,
            'count' => 1
          },
          {
            'deviceX' => 2560,
            'count' => 1
          }
        ]
      )
    end
  end
end
