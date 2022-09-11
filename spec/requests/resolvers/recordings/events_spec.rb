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
  context 'when the events are stored in S3' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site) }

    let(:list_objects_v2) do
      double(contents: [
        {
          key: "#{site.uuid}/#{recording.visitor.visitor_id}/#{recording.session_id}/1.json"
        }
      ])
    end

    let(:get_object) do
      data = { href: "http://localhost/", width: 0, height: 0 }
      events = [Event.new(event_type: Event::META, data: data, timestamp: 1625389200000)]
      double(body: double(read: events.to_json))
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
      expect(response['events']['items'].size).to eq 1
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
    context 'when there no events' do
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
        expect(response['events']['items']).to eq [
          {
            "id" => recording.events.first.id.to_s,
            "data" => "{\"href\": \"http://localhost/\", \"width\": 0, \"height\": 0}",
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
end
