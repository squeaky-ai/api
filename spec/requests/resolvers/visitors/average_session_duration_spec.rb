# typed: false
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
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

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
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:visitor_1) { create(:visitor, site_id: site.id) }
    let(:visitor_2) { create(:visitor, site_id: site.id) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          activity_duration: 3750,
          visitor_id: visitor_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          activity_duration: 1000,
          visitor_id: visitor_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          activity_duration: 1500,
          visitor_id: visitor_2.id
        }
      ]
    end

    before do
      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end
    end

    subject do
      variables = { site_id: site.id, visitor_id: visitor_1.id }
      graphql_request(visitors_average_session_duration_query, variables, user)
    end

    it 'returns the average session time for this visitor' do
      response = subject['data']['site']['visitor']
      expect(response['averageSessionDuration']).to eq 2375
    end
  end
end
