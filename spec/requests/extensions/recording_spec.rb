# frozen_string_literal: true

require 'rails_helper'

site_recording_query = <<-GRAPHQL
  query($site_id: ID!, $recording_id: ID!) {
    site(siteId: $site_id) {
      recording(recordingId: $recording_id) {
        id
        siteId
        viewerId
        active
        language
        duration
        durationString
        pageViews
        pageCount
        startPage
        exitPage
        deviceType
        browser
        browserString
        viewportX
        viewportY
        events
      }
    }
  }
GRAPHQL

RSpec.describe Types::RecordingExtension, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, recording_id: Faker::Lorem.word }
      graphql_request(site_recording_query, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['site']['recording']
      expect(response).to be nil
    end
  end

  context 'when the recording does exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:recording) { create_recording(site: site) }

    subject do
      variables = { site_id: site.id, recording_id: recording.id }
      graphql_request(site_recording_query, variables, user)
    end

    it 'returns the item' do
      response = subject['data']['site']['recording']
      expect(response).not_to be nil
    end
  end

  context 'when there are some events' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:recording) { create_recording(site: site) }

    before do
      event = { type: Event::META, data: {}, timestamp: 123 }.to_json
      Redis.current.lpush("events::#{site.uuid}::#{recording.session_id}", event)
    end

    subject do
      variables = { site_id: site.id, recording_id: recording.id }
      graphql_request(site_recording_query, variables, user)
    end

    it 'returns the events' do
      response = subject['data']['site']['recording']
      expect(response['events']).to eq ['{"type":4,"data":{},"timestamp":123}']
    end
  end
end
