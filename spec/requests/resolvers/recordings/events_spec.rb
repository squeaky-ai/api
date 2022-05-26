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
  context 'when the events are stored in S3' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site) }

    let(:list_objects_v2) do
      double(contents: [
        {
          key: "#{site.uuid}/#{recording.visitor.visitor_id}/#{recording.session_id}.json"
        }
      ])
    end

    let(:get_object) do
      events_fixtures = require_fixture('events.json')
      double(body: double(read: events_fixtures.map(&:to_json).to_json))
    end

    let(:s3_client) { instance_double(Aws::S3::Client, list_objects_v2:, get_object:) }

    before do
      allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
    end

    subject do
      variables = { site_id: site.id, recording_id: recording.id }
      graphql_request(site_recording_events_query, variables, user)
    end

    it 'returns the item with the events' do
      response = subject['data']['site']['recording']
      expect(response['events']['items'].size).to eq 88
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recording']
      expect(response['events']['pagination']).to eq(
        'perPage' => -1,
        'itemCount' => -1,
        'currentPage' => 1,
        'totalPages' => 1
      )
    end
  end

  context 'when the events are stored in the database' do
    context 'and there no events' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
      let(:recording) { create(:recording, site: site) }

      let(:list_objects_v2) { double(contents: []) }
      let(:s3_client) { instance_double(Aws::S3::Client, list_objects_v2:) }

      before do
        allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
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
          'perPage' => 500,
          'itemCount' => 0,
          'currentPage' => 1,
          'totalPages' => 0
        )
      end
    end

    context 'and there are some events' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
      let(:recording) { create(:recording, site: site) }

      let(:list_objects_v2) { double(contents: []) }
      let(:s3_client) { instance_double(Aws::S3::Client, list_objects_v2:) }

      before do
        now = Time.now
        events_fixture = require_fixture('events.json')

        events = events_fixture.map do |fixture|
          event = JSON.parse(fixture)['value']
          {
            data: event['data'],
            event_type: event['type'],
            timestamp: event['timestamp'],
            recording_id: recording.id,
            created_at: now,
            updated_at: now
          }
        end

        Event.insert_all(events)

        allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
      end

      subject do
        variables = { site_id: site.id, recording_id: recording.id }
        graphql_request(site_recording_events_query, variables, user)
      end

      it 'returns the item with the events' do
        response = subject['data']['site']['recording']
        expect(response['events']['items'].size).to eq 88
      end

      it 'returns the correct pagination' do
        response = subject['data']['site']['recording']
        expect(response['events']['pagination']).to eq(
          'perPage' => 500,
          'itemCount' => 88,
          'currentPage' => 1,
          'totalPages' => 1
        )
      end
    end
  end
end