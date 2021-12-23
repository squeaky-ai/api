# frozen_string_literal: true

require 'rails_helper'

analytics_sessions_per_visitor_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        sessionsPerVisitor {
          trend
          average
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::SessionsPerVisitor, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_sessions_per_visitor_query, variables, user)
    end

    it 'returns 0' do     
      response = subject['data']['site']['analytics']
      expect(response['sessionsPerVisitor']).to eq({ 'average' => 0, 'trend' => 0 })
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create_site_and_team(user: user) }

    before do
      visitor = create_visitor

      create_recording({ disconnected_at: Time.new(2021, 8, 7).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: visitor)
      create_recording({ disconnected_at: Time.new(2021, 8, 8).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: visitor)
      create_recording({ disconnected_at: Time.new(2021, 8, 6).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_sessions_per_visitor_query, variables, user)
    end

    it 'returns the average number of sessions per visitor' do
      response = subject['data']['site']['analytics']
      expect(response['sessionsPerVisitor']).to eq({ 'average' => 1.5, 'trend' => 1.5 })
    end
  end

  context 'when there are some recordings from the previous range' do
    let(:user) { create(:user) }
    let(:site) { create_site_and_team(user: user) }
    let(:visitor) { create_visitor }

    before do
      create_recording({ connected_at: 1628405638578, disconnected_at: 1628405639578 }, site: site, visitor: create_visitor)
      create_recording({ connected_at: 1628405636578, disconnected_at: 1628405638578 }, site: site, visitor: visitor)

      create_recording({ connected_at: 1627800838578, disconnected_at: 1627800839578 }, site: site, visitor: visitor)
      create_recording({ connected_at: 1627800836578, disconnected_at: 1627800837578 }, site: site, visitor: visitor)
      create_recording({ connected_at: 1627800836578, disconnected_at: 1627800837578 }, site: site, visitor: visitor)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_sessions_per_visitor_query, variables, user)
    end

    it 'returns the average number of views' do
      response = subject['data']['site']['analytics']
      expect(response['sessionsPerVisitor']).to eq({ 'average' => 2.5, 'trend' => -0.5 })
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create_site_and_team(user: user) }

    before do
      visitor = create_visitor

      create_recording({ disconnected_at: Time.new(2021, 8, 7).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: visitor)
      create_recording({ disconnected_at: Time.new(2021, 8, 8).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: visitor)
      create_recording({ disconnected_at: Time.new(2021, 8, 6).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: create_visitor)
      create_recording({ disconnected_at: Time.new(2021, 7, 6).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_sessions_per_visitor_query, variables, user)
    end

    it 'returns the average number of views' do
      response = subject['data']['site']['analytics']
      expect(response['sessionsPerVisitor']).to eq({ 'average' => 1.5, 'trend' => 1.5 })
    end
  end
end
