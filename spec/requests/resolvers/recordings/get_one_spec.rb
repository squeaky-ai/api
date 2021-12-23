# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

site_recording_query = <<-GRAPHQL
  query($site_id: ID!, $recording_id: ID!) {
    site(siteId: $site_id) {
      recording(recordingId: $recording_id) {
        id
        siteId
        language
        duration
        pageViews
        pageCount
        startPage
        exitPage
        device {
          browserName
          browserDetails
          viewportX
          viewportY
          deviceX
          deviceY
          deviceType
          useragent
        }
        visitor {
          id
          visitorId
        }
        previousRecording {
          id
        }
        nextRecording {
          id
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Recordings::GetOne, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, recording_id: SecureRandom.base36 }
      graphql_request(site_recording_query, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['site']['recording']
      expect(response).to be nil
    end
  end

  context 'when the recording does exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site) }

    subject do
      variables = { site_id: site.id, recording_id: recording.id }
      graphql_request(site_recording_query, variables, user)
    end

    it 'returns the item' do
      response = subject['data']['site']['recording']
      expect(response).not_to be nil
    end
  end

  context 'when the recording is soft deleted' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, deleted: true, site: site) }

    subject do
      variables = { site_id: site.id, recording_id: recording.id }
      graphql_request(site_recording_query, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['site']['recording']
      expect(response).to be nil
    end
  end

  context 'when selecting the next and previous recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recordings) { create_recordings(site: site, visitor: create_visitor, count: 3) }

    subject do
      variables = { site_id: site.id, recording_id: recordings[1].id }
      graphql_request(site_recording_query, variables, user)
    end

    it 'returns the previous recording' do
      previous_rec = subject['data']['site']['recording']['previousRecording']
      expect(previous_rec['id']).to eq recordings.first.id.to_s
    end

    it 'returns the next recording' do
      next_rec = subject['data']['site']['recording']['nextRecording']
      expect(next_rec['id']).to eq recordings.last.id.to_s
    end
  end
end
