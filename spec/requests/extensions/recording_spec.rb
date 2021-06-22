# frozen_string_literal: true

require 'rails_helper'

site_recording_query = <<-GRAPHQL
  query($site_id: ID!, $recording_id: ID!) {
    site(id: $site_id) {
      recording(id: $recording_id) {
        id
        siteId
        viewerId
        active
        language
        duration
        pageCount
        startPage
        exitPage
        browser
        deviceType
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
      variables = { site_id: site.id, recording_id: Faker::String.random(length: 4) }
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

    subject do
      variables = { site_id: site.id, recording_id: @recording.serialize[:id] }
      graphql_request(site_recording_query, variables, user)
    end

    before { @recording = create_recording(site: site) }

    after { @recording.delete! }

    it 'returns the item' do
      response = subject['data']['site']['recording']
      expect(response).not_to be nil
    end
  end
end
