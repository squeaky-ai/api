# frozen_string_literal: true

require 'rails_helper'

analytics_session_duration_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        sessionDurations {
          duration
          timestamp
        }
      }
    }
  }
GRAPHQL

RSpec.describe Types::AnalyticsSessionDurationsExtension, type: :request do
  context 'when there are no recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_session_duration_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['analytics']
      expect(response['sessionDurations']).to eq []
    end
  end

  context 'when there are some recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ connected_at: 1628405638578, disconnected_at: 1628405639578 }, site: site, visitor: create_visitor)
      create_recording({ connected_at: 1628405636578, disconnected_at: 1628405638578 }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_session_duration_query, variables, user)
    end

    it 'returns the average session time' do
      response = subject['data']['site']['analytics']
      expect(response['sessionDurations']).to match_array([
        { 'duration' => '1000', 'timestamp' => '1628405639578' },
        { 'duration' => '2000', 'timestamp' => '1628405638578' }
      ])
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ connected_at: 1628405638578, disconnected_at: 1628405639578 }, site: site, visitor: create_visitor)
      create_recording({ connected_at: 1628405636578, disconnected_at: 1628405638578 }, site: site, visitor: create_visitor)
      create_recording({ connected_at: 1628405636578, disconnected_at: 1728405640578 }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_session_duration_query, variables, user)
    end

    it 'returns the average session time' do
      response = subject['data']['site']['analytics']
      expect(response['sessionDurations']).to match_array([
        { 'duration' => '1000', 'timestamp' => '1628405639578' },
        { 'duration' => '2000', 'timestamp' => '1628405638578' }
      ])
    end
  end
end
