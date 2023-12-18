# frozen_string_literal: true

require 'rails_helper'

recording_delete_mutation = <<-GRAPHQL
  mutation($input: RecordingsDeleteInput!) {
    recordingDelete(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Recordings::Delete, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        input: {
          siteId: site.id,
          recordingId: 4564564
        }
      }
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
    let(:recording) { create(:recording, site:) }

    subject do
      variables = {
        input: {
          siteId: site.id,
          recordingId: recording.id
        }
      }
      graphql_request(recording_delete_mutation, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['recordingDelete']
      expect(response).to eq nil
    end

    it 'sets the recording to be analytics only' do
      expect { subject }.to change { Recording.find_by(id: recording.id).analytics_only? }.from(false).to(true)
    end

    it 'updates the counter cache' do
      expect { subject }.to change { Visitor.find(recording.visitor_id).recordings_count }.from(1).to(0)
    end
  end
end
