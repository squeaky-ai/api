# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

tag_remove_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $recording_id: ID!, $tag_id: ID!) {
    tagRemove(input: { siteId: $site_id, recordingId: $recording_id, tagId: $tag_id }) {
      id
      recording(recordingId: $recording_id) {
        tags {
          id
          name
        }
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::TagRemove, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, recording_id: SecureRandom.uuid, tag_id: Faker::Number.rand.to_s }
      graphql_request(tag_remove_mutation, variables, user)
    end

    it 'returns an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Recording not found'
    end
  end

  context 'when the tag does not exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:recording) { create_recording(site: site, visitor: create_visitor) }

    subject do
      variables = { site_id: site.id, recording_id: recording.id, tag_id: Faker::Number.rand.to_s }
      graphql_request(tag_remove_mutation, variables, user)
    end

    it 'returns the unmodified site' do
      tags = subject['data']['tagRemove']['recording']['tags']
      expect(tags.size).to eq 0
    end

    it 'does not remove anything' do
      expect { subject }.not_to change { recording.reload.tags.size }
    end
  end

  context 'when the tag exists' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:recording) { create_recording(site: site, visitor: create_visitor) }
    let(:tag) { create_tag(recording: recording, site: site) }

    before { tag }

    subject do
      variables = { site_id: site.id, recording_id: recording.id, tag_id: tag.id.to_s }
      graphql_request(tag_remove_mutation, variables, user)
    end

    it 'returns the updated site' do
      tags = subject['data']['tagRemove']['recording']['tags']
      expect(tags.size).to eq 0
    end

    it 'removes the tag from the recording' do
      expect { subject }.to change { recording.reload.tags.size }.from(1).to(0)
    end

    it 'does not delete the tag' do
      expect { subject }.not_to change { site.reload.tags.size }
    end
  end
end
