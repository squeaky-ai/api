# frozen_string_literal: true

require 'rails_helper'

site_recording_events_query = <<-GRAPHQL
  query($site_id: ID!, $recording_id: ID!) {
    site(siteId: $site_id) {
      recording(recordingId: $recording_id) {
        id
        events {
          items
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
  context 'when fetching events from clickhouse' do
    context 'when there no events' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      let(:recording) do
        create(:recording, site: site)
      end

      before do
        allow(ClickHouseMigration).to receive(:read?).with(site.id).and_return(true)
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

      before do
        allow(ClickHouseMigration).to receive(:read?).with(site.id).and_return(true)

        events_fixture = require_fixture('events.json')
        events = events_fixture.map { |e| JSON.parse(e)['value'] }
        
        ClickHouse::Event.insert do |buffer|
          events.each do |event|
            buffer << {
              uuid: SecureRandom.uuid,
              site_id: site.id,
              recording_id: recording.id,
              type: event['type'],
              source: event['data']['source'],
              data: event['data'].to_json,
              timestamp: event['timestamp']
            }
          end
        end
      end

      subject do
        variables = { site_id: site.id, recording_id: recording.id }
        graphql_request(site_recording_events_query, variables, user)
      end

      it 'returns the correct amount of events' do
        response = subject['data']['site']['recording']
        expect(response['events']['items'].size).to eq 88
      end

      it 'returns the correct pagination' do
        response = subject['data']['site']['recording']
        expect(response['events']['pagination']).to eq(
          'perPage' => 250,
          'itemCount' => 88,
          'currentPage' => 1,
          'totalPages' => 1
        )
      end
    end
  end

  context 'when fetching events from postgres' do
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

      let(:recording) do
        rec = create(:recording, site: site)

        data = { href: "http://localhost/", width: 0, height: 0 }
        rec.events << Event.new(event_type: Event::META, data: data, timestamp: 1625389200000)

        rec
      end

      subject do
        variables = { site_id: site.id, recording_id: recording.id }
        graphql_request(site_recording_events_query, variables, user)
      end

      it 'returns the item with the events' do
        response = subject['data']['site']['recording']
        expect(response['events']['items']).to eq ["{\"id\":#{recording.events.first.id},\"data\":{\"href\":\"http://localhost/\",\"width\":0,\"height\":0},\"type\":4,\"timestamp\":1625389200000}"]
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
end
