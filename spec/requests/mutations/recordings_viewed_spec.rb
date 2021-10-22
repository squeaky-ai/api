# frozen_string_literal: true

require 'rails_helper'

recordings_viewed_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $recording_ids: [String!]!, $viewed: Boolean!) {
    recordingsViewed(input: { siteId: $site_id, recordingIds: $recording_ids, viewed: $viewed }) {
      recordings {
        items {
          id
          viewed
        }
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::RecordingViewed, type: :request do
  context 'when none of the recordings exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, recording_ids: ['23423423423'], viewed: true }
      graphql_request(recordings_viewed_mutation, variables, user)
    end

    it 'returns the site' do
      response = subject['data']['recordingsViewed']['recordings']
      expect(response['items']).to eq []
    end
  end

  context 'when some of the recordings exist and they are marked as viewed' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    let(:recording_1) { create_recording({ viewed: true }, site: site, visitor: create_visitor, in_es: true) }
    let(:recording_2) { create_recording(site: site, visitor: create_visitor, in_es: true) }
    let(:recording_3) { create_recording(site: site, visitor: create_visitor, in_es: true) }

    before do 
      recording_1
      recording_2
      recording_3
    end

    subject do
      variables = { site_id: site.id, recording_ids: [recording_1.id.to_s, recording_2.id.to_s, '1231232131'], viewed: true }
      graphql_request(recordings_viewed_mutation, variables, user)
    end

    it 'returns the site' do
      response = subject['data']['recordingsViewed']['recordings']
      expect(response['items']).to match_array([
        { 'id' => recording_1.id.to_s, 'viewed' => true },
        { 'id' => recording_2.id.to_s, 'viewed' => true },
        { 'id' => recording_3.id.to_s, 'viewed' => false }
      ])
    end

    it 'sets the recordings as viewed' do
      expect { subject }.to change { site.recordings.reload.where(viewed: true).size }.from(1).to(2)
    end
  end

  context 'when some of the recordings exist and they are marked as not viewed' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    let(:recording_1) { create_recording({ viewed: true }, site: site, visitor: create_visitor, in_es: true) }
    let(:recording_2) { create_recording(site: site, visitor: create_visitor, in_es: true) }
    let(:recording_3) { create_recording({ viewed: true }, site: site, visitor: create_visitor, in_es: true) }

    before do 
      recording_1
      recording_2
      recording_3
    end

    subject do
      variables = { site_id: site.id, recording_ids: [recording_1.id.to_s, recording_2.id.to_s, '1231232131'], viewed: false }
      graphql_request(recordings_viewed_mutation, variables, user)
    end

    it 'returns the site' do
      response = subject['data']['recordingsViewed']['recordings']
      expect(response['items']).to match_array([
        { 'id' => recording_1.id.to_s, 'viewed' => false },
        { 'id' => recording_2.id.to_s, 'viewed' => false },
        { 'id' => recording_3.id.to_s, 'viewed' => true }
      ])
    end

    it 'sets the recordings as viewed' do
      expect { subject }.to change { site.recordings.reload.where(viewed: true).size }.from(2).to(1)
    end
  end
end