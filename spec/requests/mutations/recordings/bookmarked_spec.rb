# frozen_string_literal: true

require 'rails_helper'

recording_bookmarked_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $recording_id: ID!, $bookmarked: Boolean!) {
    recordingBookmarked(input: { siteId: $site_id, recordingId: $recording_id, bookmarked: $bookmarked }) {
      id
      bookmarked
    }
  }
GRAPHQL

RSpec.describe Mutations::Recordings::Bookmarked, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, recording_id: 234234, bookmarked: false }
      graphql_request(recording_bookmarked_mutation, variables, user)
    end

    it 'throws an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Recording not found'
    end
  end

  context 'when the recording does exist' do
    context 'and it is bookmarked' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
      let(:recording) { create(:recording, site: site) }

      subject do
        variables = { site_id: site.id, recording_id: recording.id, bookmarked: true }
        graphql_request(recording_bookmarked_mutation, variables, user)
      end

      it 'marks the site as bookmarked' do
        response = subject['data']['recordingBookmarked']
        expect(response['bookmarked']).to be true
      end

      it 'updates the recording in the database' do
        expect { subject }.to change { Recording.find_by(id: recording.id).bookmarked }.from(false).to(true)
      end
    end

    context 'and it is unbookmarked' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
      let(:recording) { create(:recording, bookmarked: true, site: site) }

      subject do
        variables = { site_id: site.id, recording_id: recording.id, bookmarked: false }
        graphql_request(recording_bookmarked_mutation, variables, user)
      end

      it 'marks the site as unbookmarked' do
        response = subject['data']['recordingBookmarked']
        expect(response['bookmarked']).to be false
      end

      it 'updates the recording in the database' do
        expect { subject }.to change { Recording.find_by(id: recording.id).bookmarked }.from(true).to(false)
      end
    end
  end
end
