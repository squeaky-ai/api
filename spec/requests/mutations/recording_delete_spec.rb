# frozen_string_literal: true

require 'rails_helper'

recording_delete_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $recording_id: ID!) {
    recordingDelete(input: { siteId: $site_id, recordingId: $recording_id }) {
      recording(recordingId: $recording_id) {
        id
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::RecordingDelete, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, recording_id: Faker::Number.number(digits: 5) }
      graphql_request(recording_delete_mutation, variables, user)
    end

    it 'throws an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Recording not found'
    end
  end

  context 'when the recording does exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:recording) { create_recording(site: site, visitor: create_visitor, in_es: true) }

    subject do
      variables = { site_id: site.id, recording_id: recording.id }
      graphql_request(recording_delete_mutation, variables, user)
    end

    it 'returns null for the site' do
      response = subject['data']['recordingDelete']['recording']
      expect(response).to be nil
    end

    it 'soft deletes the recording' do
      expect { subject }.to change { Recording.find_by(id: recording.id).deleted }.from(false).to(true)
    end
  end
end