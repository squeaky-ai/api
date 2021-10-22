# frozen_string_literal: true

require 'rails_helper'

analytics_visitor_session_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        averageSessionsPerVisitor
      }
    }
  }
GRAPHQL

RSpec.describe Types::AnalyticsPagesPerSessionExtension, type: :request do
  context 'when there are no recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_visitor_session_query, variables, user)
    end

    it 'returns 0' do
      response = subject['data']['site']['analytics']
      expect(response['averageSessionsPerVisitor']).to eq 0
    end
  end

  context 'when there are some recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      visitor = create_visitor

      create_recording({ disconnected_at: Time.new(2021, 8, 7).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: visitor)
      create_recording({ disconnected_at: Time.new(2021, 8, 8).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: visitor)
      create_recording({ disconnected_at: Time.new(2021, 8, 6).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_visitor_session_query, variables, user)
    end

    it 'returns the average number of sessions per visitor' do
      response = subject['data']['site']['analytics']
      expect(response['averageSessionsPerVisitor']).to eq 1.5
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create_user }
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
      graphql_request(analytics_visitor_session_query, variables, user)
    end

    it 'returns the average number of views' do
      response = subject['data']['site']['analytics']
      expect(response['averageSessionsPerVisitor']).to eq 1.5
    end
  end
end
