# frozen_string_literal: true

require 'rails_helper'

site_recording_query = <<-GRAPHQL
  query($site_id: ID!, $recording_id: ID!) {
    site(siteId: $site_id) {
      recording(recordingId: $recording_id) {
        id
        siteId
        viewerId
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
end
