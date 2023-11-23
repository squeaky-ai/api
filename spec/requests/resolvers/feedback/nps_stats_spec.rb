# frozen_string_literal: true

require 'rails_helper'

nps_stats_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      nps(fromDate: $from_date, toDate: $to_date) {
        stats {
          displays
          ratings
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Feedback::NpsStats, type: :request do
  context 'when there is no data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(nps_stats_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['nps']
      expect(response['stats']).to eq(
        'displays' => 0,
        'ratings' => 0
      )
    end
  end

  context 'when there is some data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:visitor) { create(:visitor) }
    let(:recording_1) { create(:recording, disconnected_at: Time.new(2021, 8, 3).to_i * 1000, site:, visitor:) }
    let(:recording_2) { create(:recording, disconnected_at: Time.new(2021, 8, 3).to_i * 1000, site:, visitor:) }
    let(:recording_3) { create(:recording, site:, visitor:) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_1.id,
          visitor_id: recording_1.visitor_id,
          disconnected_at: recording_1['disconnected_at']
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_2.id,
          visitor_id: recording_2.visitor_id,
          disconnected_at: recording_2['disconnected_at']
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_3.id,
          visitor_id: recording_3.visitor_id,
          disconnected_at: recording_3['disconnected_at']
        }
      ]
    end

    before do
      create(:nps, score: 5, created_at: Time.new(2021, 8, 3).utc, recording: recording_1)
      create(:nps, score: 3, created_at: Time.new(2021, 8, 3).utc, recording: recording_2)
      create(:nps, score: 3, created_at: Time.new(2020, 8, 3).utc, recording: recording_3)

      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(nps_stats_query, variables, user)
    end

    it 'returns the data' do
      response = subject['data']['site']['nps']
      expect(response['stats']).to eq(
        'displays' => 2,
        'ratings' => 2
      )
    end
  end
end
