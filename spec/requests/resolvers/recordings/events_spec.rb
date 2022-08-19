# frozen_string_literal: true

require 'rails_helper'

site_recording_events_query = <<-GRAPHQL
  query($site_id: ID!, $recording_id: ID!) {
    site(siteId: $site_id) {
      recording(recordingId: $recording_id) {
        id
        events {
          items {
            id
            data
            type
            timestamp
          }
          pagination {
            perPage
            itemCount
            currentPage
            totalPages
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Recordings::Events, type: :request do
  context 'when there no events' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recording) do
      create(:recording, site: site)
    end

    subject do
      variables = { site_id: site.id, recording_id: recording.id }
      graphql_request(site_recording_events_query, variables, user)
    end

    it 'returns the item with the events' do
      response = subject['data']['site']['recording']
      expect(response['events']['items']).to eq []
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recording']
      expect(response['events']['pagination']).to eq(
        'perPage' => 250,
        'itemCount' => 0,
        'currentPage' => 1,
        'totalPages' => 0
      )
    end
  end

  context 'when there are some events' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site) }
    let(:event_uuid) { SecureRandom.uuid }

    before do
      ClickHouse::Event.insert do |buffer|
        buffer << {
          uuid: event_uuid,
          site_id: recording.site_id,
          recording_id: recording.id,
          type: Event::META,
          data: { href: 'http://localhost/', width: 0, height: 0 }.to_json,
          timestamp: 1625389200000
        }
      end
    end

    subject do
      variables = { site_id: site.id, recording_id: recording.id }
      graphql_request(site_recording_events_query, variables, user)
    end

    it 'returns the item with the events' do
      response = subject['data']['site']['recording']
      expect(response['events']['items']).to eq [
        {
          "id" => event_uuid,
          "data" => "{\"href\":\"http://localhost/\",\"width\":0,\"height\":0}",
          "type" => 4,
          "timestamp" => "1625389200000"
        }
      ]
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recording']
      expect(response['events']['pagination']).to eq(
        'perPage' => 250,
        'itemCount' => 1,
        'currentPage' => 1,
        'totalPages' => 1
      )
    end
  end
end
