# frozen_string_literal: true

require 'rails_helper'

recording_viewed_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $recording_id: ID!) {
    recordingViewed(input: { siteId: $site_id, recordingId: $recording_id }) {
      id
      recording(recordingId: $recording_id) {
        id
        viewed
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::RecordingViewed, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, recording_id: Faker::Number.number(digits: 5) }
      graphql_request(recording_viewed_mutation, variables, user)
    end

    it 'throws an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Recording not found'
    end
  end

  context 'when the recording does exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:recording) { create_recording(site: site )}

    subject do
      variables = { site_id: site.id, recording_id: recording.id }
      graphql_request(recording_viewed_mutation, variables, user)
    end

    it 'marks the site as recorded' do
      response = subject['data']['recordingViewed']['recording']
      expect(response['viewed']).to be true
    end

    it 'updates the recording in the database' do
      expect { subject }.to change { Recording.find_by(id: recording.id).viewed }.from(false).to(true)
    end
  end
end
