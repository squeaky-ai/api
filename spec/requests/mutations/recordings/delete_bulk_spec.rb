# frozen_string_literal: true

require 'rails_helper'

recordings_delete_mutation = <<-GRAPHQL
  mutation($input: RecordingsDeleteBulkInput!) {
    recordingsDelete(input: $input) {
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
        input: {
          siteId: site.id,
          recordingIds: ['23423423423']
        }
      }

      graphql_request(recordings_delete_mutation, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['recordingsDelete']
      expect(response).to eq []
    end

    it 'does not update the recordings count' do
      expect { subject }.not_to(change { site.reload.recordings.size })
    end
  end

  context 'when some of the recordings exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let!(:recording_1) { create(:recording, site:) }
    let!(:recording_2) { create(:recording, site:) }
    let!(:recording_3) { create(:recording, site:) }

    subject do
      variables = {
        input: {
          siteId: site.id,
          recordingIds: [recording_1.id.to_s, recording_2.id.to_s, '1231232131']
        }
      }

      graphql_request(recordings_delete_mutation, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['recordingsDelete']
      expect(response).to eq []
    end

    it 'sets the recording as analytics only' do
      expect { subject }.to change { site.recordings.reload.where(status: Recording::ACTIVE).size }.from(3).to(1)
    end

    it 'updates the counter cache' do
      expect { subject }.to change { recording_1.visitor.reload.recordings_count }.from(1).to(0)
        .and change {
               recording_2.visitor.reload.recordings_count
             }.from(1).to(0)
        .and change {
               recording_3.visitor.reload.recordings_count
             }.by(0)
    end
  end
end
