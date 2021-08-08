# frozen_string_literal: true

require 'rails_helper'

visitors_average_session_duration_query = <<-GRAPHQL
  query($site_id: ID!, $viewer_id: ID!) {
    site(siteId: $site_id) {
      visitor(viewerId: $viewer_id) {
        averageSessionDuration
      }
    }
  }
GRAPHQL

RSpec.describe Types::VisitorAverageSessionDurationExtension, type: :request do
  context 'when there are no recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:viewer_id) { 'aaaaaaa' }

    subject do
      variables = { site_id: site.id, viewer_id: viewer_id }
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
    let(:viewer_id) { 'aaaaaaa' }

    before do
      create_recording({ deleted: true, viewer_id: viewer_id, connected_at: 1628405638578, disconnected_at: 1628405639578 }, site: site)
      create_recording({ deleted: true, viewer_id: viewer_id, connected_at: 1628405636578, disconnected_at: 1628405638578 }, site: site)
      create_recording({ deleted: true, viewer_id: 'bbbbbbb', connected_at: 1628405636578, disconnected_at: 1628405640578 }, site: site)
    end

    subject do
      variables = { site_id: site.id, viewer_id: viewer_id }
      graphql_request(visitors_average_session_duration_query, variables, user)
    end

    it 'returns the average session time for this viewer' do
      response = subject['data']['site']['visitor']
      expect(response['averageSessionDuration']).to eq 1500
    end
  end
end
