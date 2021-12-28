# frozen_string_literal: true

require 'rails_helper'

recording_delete_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $recording_id: ID!) {
    recordingDelete(input: { siteId: $site_id, recordingId: $recording_id }) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Recordings::Delete, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, recording_id: 4564564 }
      graphql_request(recording_delete_mutation, variables, user)
    end

    it 'throws an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Recording not found'
    end
  end

  context 'when the recording does exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site) }

    subject do
      variables = { site_id: site.id, recording_id: recording.id }
      graphql_request(recording_delete_mutation, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['recordingDelete']
      expect(response).to eq nil
    end

    it 'soft deletes the recording' do
      expect { subject }.to change { Recording.find_by(id: recording.id).deleted? }.from(false).to(true)
    end
  end
end