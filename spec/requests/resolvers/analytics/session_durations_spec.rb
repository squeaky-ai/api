# frozen_string_literal: true

require 'rails_helper'

analytics_session_duration_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!) {
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
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

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
      expect(response['sessionDurations']).to eq({ 'average' => '1500', 'trend' => '1500' })
    end
  end

  context 'when there are some recordings from the previous range' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ connected_at: 1628405638578, disconnected_at: 1628405639578 }, site: site, visitor: create_visitor)
      create_recording({ connected_at: 1628405636578, disconnected_at: 1628405638578 }, site: site, visitor: create_visitor)

      create_recording({ connected_at: 1627800838578, disconnected_at: 1627800839578 }, site: site, visitor: create_visitor)
      create_recording({ connected_at: 1627800836578, disconnected_at: 1627800837578 }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_session_duration_query, variables, user)
    end

    it 'returns the average session time' do
      response = subject['data']['site']['analytics']
      expect(response['sessionDurations']).to eq({ 'average' => '1250', 'trend' => '250' })
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
      expect(response['sessionDurations']).to eq({ 'average' => '1500', 'trend' => '1500' })
    end
  end
end
