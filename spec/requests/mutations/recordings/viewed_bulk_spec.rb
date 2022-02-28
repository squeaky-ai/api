# frozen_string_literal: true

require 'rails_helper'

recordings_viewed_mutation = <<-GRAPHQL
  mutation($input: RecordingsViewedBulkInput!) {
    recordingsViewed(input: $input) {
      id
      viewed
    }
  }
GRAPHQL

RSpec.describe Mutations::Recordings::ViewedBulk, type: :request do
  context 'when none of the recordings exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        input: { 
          siteId: site.id, 
          recordingIds: ['23423423423'], 
          viewed: true
        }
      }
      graphql_request(recordings_viewed_mutation, variables, user)
    end

    it 'returns the site' do
      response = subject['data']['recordingsViewed']
      expect(response).to eq []
    end
  end

  context 'when some of the recordings exist and they are marked as viewed' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recording_1) { create(:recording, viewed: true, site: site) }
    let(:recording_2) { create(:recording, site: site) }
    let(:recording_3) { create(:recording, site: site) }

    before do 
      recording_1
      recording_2
      recording_3
    end

    subject do
      variables = {
        input: { 
          siteId: site.id, 
          recordingIds: [recording_1.id.to_s, recording_2.id.to_s, '1231232131'], 
          viewed: true
        }
      }

      graphql_request(recordings_viewed_mutation, variables, user)
    end

    it 'returns the site' do
      response = subject['data']['recordingsViewed']
      expect(response).to match_array([
        { 'id' => recording_1.id.to_s, 'viewed' => true },
        { 'id' => recording_2.id.to_s, 'viewed' => true },
        { 'id' => recording_3.id.to_s, 'viewed' => false }
      ])
    end

    it 'sets the recordings as viewed' do
      expect { subject }.to change { site.recordings.reload.where(viewed: true).size }.from(1).to(2)
    end

    it 'sets the visitors of the recordings as not-new' do
      expect { subject }.to change { site.visitors.reload.where(new: true).size }.from(3).to(1)
    end
  end

  context 'when some of the recordings exist and they are marked as not viewed' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recording_1) { create(:recording, viewed: true, site: site) }
    let(:recording_2) { create(:recording, site: site) }
    let(:recording_3) { create(:recording, viewed: true, site: site) }

    before do 
      recording_1
      recording_2
      recording_3
    end

    subject do
      variables = {
        input: { 
          siteId: site.id, 
          recordingIds: [recording_1.id.to_s, recording_2.id.to_s, '1231232131'], 
          viewed: false
        }
      }

      graphql_request(recordings_viewed_mutation, variables, user)
    end

    it 'returns the site' do
      response = subject['data']['recordingsViewed']
      expect(response).to match_array([
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