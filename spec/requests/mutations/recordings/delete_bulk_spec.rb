# frozen_string_literal: true

require 'rails_helper'

recordings_delete_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $recording_ids: [String!]!, $from_date: String!, $to_date: String!) {
    recordingsDelete(input: { siteId: $site_id, recordingIds: $recording_ids }) {
      recordings(fromDate: $from_date, toDate: $to_date) {
        items {
          id
        }
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Recordings::DeleteBulk, type: :request do
  context 'when none of the recordings exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      today = Time.now.strftime('%Y-%m-%d')

      variables = { 
        site_id: site.id, 
        recording_ids: ['23423423423'], 
        from_date: today, 
        to_date: today 
      }

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
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recording_1) { create_recording(site: site, visitor: create_visitor) }
    let(:recording_2) { create_recording(site: site, visitor: create_visitor) }
    let(:recording_3) { create_recording(site: site, visitor: create_visitor) }

    before do 
      recording_1
      recording_2
      recording_3
    end

    subject do
      today = Time.now.strftime('%Y-%m-%d')

      variables = { 
        site_id: site.id, 
        recording_ids: [recording_1.id.to_s, recording_2.id.to_s, '1231232131'], 
        from_date: today, 
        to_date: today 
      }

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