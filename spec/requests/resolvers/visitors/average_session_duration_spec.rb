# frozen_string_literal: true

require 'rails_helper'

visitors_average_session_duration_query = <<-GRAPHQL
  query($site_id: ID!, $visitor_id: ID!) {
    site(siteId: $site_id) {
      visitor(visitorId: $visitor_id) {
        averageSessionDuration
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Visitors::AverageSessionDuration, type: :request do
  context 'when there are no recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, visitor_id: 1 }
      graphql_request(visitors_average_session_duration_query, variables, user)
    end

    it 'returns nil for the visitor' do
      response = subject['data']['site']['visitor']
      expect(response).to be nil
    end
  end

  context 'when there are some recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:visitor) { create_visitor }

    before do
      create_recording({ connected_at: 1628405638578, disconnected_at: 1628405639578 }, site: site, visitor: visitor)
      create_recording({ connected_at: 1628405636578, disconnected_at: 1628405638578 }, site: site, visitor: visitor)
      create_recording({ connected_at: 1628405636578, disconnected_at: 1628405640578 }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, visitor_id: visitor.id }
      graphql_request(visitors_average_session_duration_query, variables, user)
    end

    it 'returns the average session time for this visitor' do
      response = subject['data']['site']['visitor']
      expect(response['averageSessionDuration']).to eq 1500
    end
  end
end
