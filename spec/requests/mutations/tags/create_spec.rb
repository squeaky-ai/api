# frozen_string_literal: true

require 'rails_helper'

tag_create_mutation = <<-GRAPHQL
  mutation($input: TagsCreateInput!) {
    tagCreate(input: $input) {
      id
      name
    }
  }
GRAPHQL

RSpec.describe Mutations::Tags::Create, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:name) { 'Anteater' }

    subject do
      variables = {
        input: {
          siteId: site.id,
          recordingId: SecureRandom.uuid,
          name:
        }
      }
      graphql_request(tag_create_mutation, variables, user)
    end

    it 'returns an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Recording not found'
    end
  end

  context 'when the recording exists' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site:) }
    let(:name) { 'Carpet' }

    subject do
      variables = {
        input: {
          siteId: site.id,
          recordingId: recording.id,
          name:
        }
      }
      graphql_request(tag_create_mutation, variables, user)
    end

    it 'returns the created tag' do
      tags = subject['data']['tagCreate']
      expect(tags['name']).to eq name
    end

    it 'creates the record' do
      expect { subject }.to change { recording.reload.tags.size }.from(0).to(1)
    end
  end

  context 'when a tag with that name exists already' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site:) }
    let(:name) { 'Plant' }

    before do
      recording.tags << Tag.new(name:, site_id: site.id)
      recording.save
    end

    subject do
      variables = {
        input: {
          siteId: site.id,
          recordingId: recording.id,
          name:
        }
      }
      graphql_request(tag_create_mutation, variables, user)
    end

    it 'returns the existing tag' do
      tags = subject['data']['tagCreate']
      expect(tags['name']).to eq name
    end

    it 'does note create the record' do
      expect { subject }.not_to(change { recording.reload.tags.size })
    end
  end
end
