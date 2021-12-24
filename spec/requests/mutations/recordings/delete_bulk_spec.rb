# frozen_string_literal: true

require 'rails_helper'

recordings_delete_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $recording_ids: [String!]!) {
    recordingsDelete(input: { siteId: $site_id, recordingIds: $recording_ids }) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Recordings::DeleteBulk, type: :request do
  context 'when none of the recordings exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { 
        site_id: site.id, 
        recording_ids: ['23423423423']
      }

      graphql_request(recordings_delete_mutation, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['recordingsDelete']
      expect(response).to eq []
    end

    it 'does not update the recordings count' do
      expect { subject }.not_to change { site.reload.recordings.size }
    end
  end

  context 'when some of the recordings exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recording_1) { create(:recording, site: site) }
    let(:recording_2) { create(:recording, site: site) }
    let(:recording_3) { create(:recording, site: site) }

    before do 
      recording_1
      recording_2
      recording_3
    end

    subject do
      variables = { 
        site_id: site.id, 
        recording_ids: [recording_1.id.to_s, recording_2.id.to_s, '1231232131']
      }

      graphql_request(recordings_delete_mutation, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['recordingsDelete']
      expect(response).to eq []
    end

    it 'soft deletes the recordings' do
      expect { subject }.to change { site.recordings.reload.where(deleted: false).size }.from(3).to(1)
    end
  end
end