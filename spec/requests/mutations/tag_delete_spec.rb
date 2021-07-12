# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

tag_delete_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $session_id: ID!, $tag_id: ID!) {
    tagDelete(input: { siteId: $site_id, sessionId: $session_id, tagId: $tag_id }) {
      id
      recording(id: $session_id) {
        tags {
          id
          name
        }
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::TagUpdate, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, session_id: SecureRandom.uuid, tag_id: Faker::Number.rand.to_s }
      graphql_request(tag_delete_mutation, variables, user)
    end

    it 'returns an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Recording not found'
    end
  end

  context 'when the tag does not exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:recording) { create_recording(site: site) }

    subject do
      variables = { site_id: site.id, session_id: recording.session_id, tag_id: Faker::Number.rand.to_s }
      graphql_request(tag_delete_mutation, variables, user)
    end

    it 'returns the unmodified site' do
      tags = subject['data']['tagDelete']['recording']['tags']
      expect(tags.size).to eq 0
    end

    it 'does not delete anything' do
      expect { subject }.not_to change { recording.reload.tags.size }
    end
  end

  context 'when the tag exists' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:recording) { create_recording(site: site) }
    let(:tag) { create_tag(recording: recording) }

    before { tag }

    subject do
      variables = { site_id: site.id, session_id: recording.session_id, tag_id: tag.id.to_s }
      graphql_request(tag_delete_mutation, variables, user)
    end

    it 'returns the updated site' do
      tags = subject['data']['tagDelete']['recording']['tags']
      expect(tags.size).to eq 0
    end

    it 'deletes the record' do
      expect { subject }.to change { recording.reload.tags.size }.from(1).to(0)
    end
  end
end
