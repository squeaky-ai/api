# frozen_string_literal: true

require 'rails_helper'

site_recording_query = <<-GRAPHQL
  query($site_id: ID!, $session_id: ID!) {
    site(id: $site_id) {
      recording(id: $session_id) {
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
        dateString
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
      variables = { site_id: site.id, session_id: Faker::Lorem.word }
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
      variables = { site_id: site.id, session_id: recording.session_id }
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

    let(:recording) do
      rec = create_recording(site: site)

      data = { href: "http://localhost/", width: 0, height: 0 }
      rec.events << Event.new(event_type: Event::META, data: data, timestamp: 1625389200000)

      rec
    end

    subject do
      variables = { site_id: site.id, session_id: recording.session_id }
      graphql_request(site_recording_query, variables, user)
    end

    it 'returns the item with the events' do
      response = subject['data']['site']['recording']
      expect(response['events']).not_to be nil
    end
  end
end
