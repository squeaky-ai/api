# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

tag_update_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $recording_id: ID!, $tag_id: ID!, $name: String!) {
    tagUpdate(input: { siteId: $site_id, recordingId: $recording_id, tagId: $tag_id, name: $name }) {
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

RSpec.describe Mutations::TagUpdate, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:name) { Faker::Book.title }

    subject do
      variables = { site_id: site.id, recording_id: SecureRandom.uuid, tag_id: Faker::Number.rand.to_s, name: name }
      graphql_request(tag_update_mutation, variables, user)
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
    let(:name) { Faker::Book.title }

    subject do
      variables = { site_id: site.id, recording_id: recording.id, tag_id: Faker::Number.rand.to_s, name: name }
      graphql_request(tag_update_mutation, variables, user)
    end

    it 'returns the unmodified site' do
      tags = subject['data']['tagUpdate']['recording']['tags']
      expect(tags.size).to eq 0
    end

    it 'does not upsert a tag' do
      expect { subject }.not_to change { recording.reload.tags.size }
    end
  end

  context 'when the tag exists' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:recording) { create_recording(site: site, visitor: create_visitor) }
    let(:tag) { create_tag(recording: recording) }
    let(:name) { Faker::Book.title }

    subject do
      variables = { site_id: site.id, recording_id: recording.id, tag_id: tag.id.to_s, name: name }
      graphql_request(tag_update_mutation, variables, user)
    end

    it 'returns the updated site' do
      tags = subject['data']['tagUpdate']['recording']['tags']
      expect(tags.size).to eq 1
      expect(tags[0]['name']).to eq name
    end

    it 'updates the record' do
      expect { subject }.to change { recording.reload.tags[0].name }.from(tag.name).to(name)
    end
  end
end
