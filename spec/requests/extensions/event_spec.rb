# frozen_string_literal: true

require 'rails_helper'

site_events_query = <<-GRAPHQL
  query($site_id: ID!, $session_id: ID!) {
    site(id: $site_id) {
      recording(id: $session_id) {
        events {
          ... on Snapshot {
            type
            event
            snapshot
            timestamp
          }
          ... on PageView {
            type
            locale
            useragent
            path
            timestamp
          }
          ... on Scroll {
            type
            x
            y
            timestamp
          }
          ... on Cursor {
            type
            x
            y
            timestamp
          }
          ... on Interaction {
            type
            selector
            timestamp
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Types::EventsExtension, type: :request do
  context 'when there are no events' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before { @recording = create_recording(site: site) }

    subject do
      variables = { site_id: site.id, session_id: @recording.session_id }
      graphql_request(site_events_query, variables, user)
    end

    it 'returns no items' do
      events = subject['data']['site']['recording']['events']
      expect(events).to eq []
    end
  end

  context 'when there are several events' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      @recording = create_recording(site: site)
      create_events(count: 5, site_id: site.id, session_id: @recording.session_id)
    end

    subject do
      variables = { site_id: site.id, session_id: @recording.session_id }
      graphql_request(site_events_query, variables, user)
    end

    it 'returns some items' do
      events = subject['data']['site']['recording']['events']
      expect(events.size).to eq 5
    end

    it 'returns the events in ascending order' do
      events = subject['data']['site']['recording']['events']
      timestamps = events.map { |i| i['timestamp'].to_i }

      expect(timestamps).to eq timestamps.sort
    end
  end
end
