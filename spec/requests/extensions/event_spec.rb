# frozen_string_literal: true

require 'rails_helper'

site_recording_events_query = <<-GRAPHQL
  query($site_id: ID!, $recording_id: ID!) {
    site(siteId: $site_id) {
      recording(recordingId: $recording_id) {
        id
        events
      }
    }
  }
GRAPHQL

RSpec.describe Types::EventExtension, type: :request do
  context 'when there no events' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    let(:recording) do
      create_recording(site: site)
    end

    subject do
      variables = { site_id: site.id, recording_id: recording.id }
      graphql_request(site_recording_events_query, variables, user)
    end

    it 'returns the item with the events' do
      response = subject['data']['site']['recording']
      expect(response['events']).to eq '[]'
    end
  end

  context 'when there are some events' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    let(:recording) do
      rec = create_recording(site: site)

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
      expect(response['events']).to eq "[{\"id\":#{recording.events.first.id},\"data\":{\"href\":\"http://localhost/\",\"width\":0,\"height\":0},\"type\":4,\"timestamp\":1625389200000}]"
    end
  end
end