# frozen_string_literal: true

require 'rails_helper'

analytics_session_duration_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        sessionDurations {
          average
          trend
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::SessionDurations, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_session_duration_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['analytics']
      expect(response['sessionDurations']).to eq({ 'average' => '0', 'trend' => '0' })
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
          disconnected_at: 1628405639578,
          activity_duration: 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: 1628405638578,
          activity_duration: 4000
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
      graphql_request(analytics_session_duration_query, variables, user)
    end

    it 'returns the average session time' do
      response = subject['data']['site']['analytics']
      expect(response['sessionDurations']).to eq({ 'average' => '2500', 'trend' => '2500' })
    end
  end

  context 'when there are some recordings from the previous range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: 1628405639578,
          activity_duration: 1750
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: 1628405638578,
          activity_duration: 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: 1627800838578,
          activity_duration: 2000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: 1627800837578,
          activity_duration: 1300
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
      graphql_request(analytics_session_duration_query, variables, user)
    end

    it 'returns the average session time' do
      response = subject['data']['site']['analytics']
      expect(response['sessionDurations']).to eq({ 'average' => '1512', 'trend' => '-137' })
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
          disconnected_at: 1628405639578,
          activity_duration: 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: 1628405638578,
          activity_duration: 3000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: 1728405640578,
          activity_duration: 2750
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
      graphql_request(analytics_session_duration_query, variables, user)
    end

    it 'returns the average session time' do
      response = subject['data']['site']['analytics']
      expect(response['sessionDurations']).to eq({ 'average' => '2000', 'trend' => '2000' })
    end
  end
end
