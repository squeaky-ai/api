# frozen_string_literal: true

require 'rails_helper'

recordings_delete_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $recording_ids: [String!]!) {
    recordingsDelete(input: { siteId: $site_id, recordingIds: $recording_ids }) {
      recordings {
        items {
          id
        }
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Recordings::DeleteBulk, type: :request do
  context 'when none of the recordings exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, recording_ids: ['23423423423'] }
      graphql_request(recordings_delete_mutation, variables, user)
    end

    it 'returns the site' do
      response = subject['data']['recordingsDelete']['recordings']
      expect(response['items']).to eq []
    end

    it 'does not update the recordings count' do
      expect { subject }.not_to change { site.reload.recordings.size }
    end
  end

  context 'when some of the recordings exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    let(:recording_1) { create_recording(site: site, visitor: create_visitor, in_es: true) }
    let(:recording_2) { create_recording(site: site, visitor: create_visitor, in_es: true) }
    let(:recording_3) { create_recording(site: site, visitor: create_visitor, in_es: true) }

    before do 
      recording_1
      recording_2
      recording_3
    end

    subject do
      variables = { site_id: site.id, recording_ids: [recording_1.id.to_s, recording_2.id.to_s, '1231232131'] }
      graphql_request(recordings_delete_mutation, variables, user)
    end

    it 'returns the site' do
      response = subject['data']['recordingsDelete']['recordings']
      expect(response['items']).to eq [{ 'id' => recording_3.id.to_s }]
    end

    it 'soft deletes the recording' do
      expect { subject }.to change { site.recordings.reload.where(deleted: false).size }.from(3).to(1)
    end
  end
end