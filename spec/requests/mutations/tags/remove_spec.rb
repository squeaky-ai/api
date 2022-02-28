# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

tag_remove_mutation = <<-GRAPHQL
  mutation($input: TagsRemoveInput!) {
    tagRemove(input: $input) {
      id
      name
    }
  }
GRAPHQL

RSpec.describe Mutations::Tags::Remove, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        input: { 
          siteId: site.id, 
          recordingId: SecureRandom.uuid, 
          tagId: 345345 
        }
      }
      graphql_request(tag_remove_mutation, variables, user)
    end

    it 'returns an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Recording not found'
    end
  end

  context 'when the tag does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site) }

    subject do
      variables = {
        input: { 
          siteId: site.id, 
          recordingId: recording.id, 
          tagId: 23423423 
        }
      }
      graphql_request(tag_remove_mutation, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['tagRemove']
      expect(response).to eq nil
    end

    it 'does not remove anything' do
      expect { subject }.not_to change { recording.reload.tags.size }
    end
  end

  context 'when the tag exists' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site) }
    let(:tag) { create(:tag, site_id: site.id) }

    before do
      recording.tags << tag
      recording.save
    end

    subject do
      variables = {
        input: { 
          siteId: site.id, 
          recordingId: recording.id, 
          tagId: tag.id.to_s 
        }
      }
      graphql_request(tag_remove_mutation, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['tagRemove']
      expect(response).to eq nil
    end

    it 'removes the tag from the recording' do
      expect { subject }.to change { recording.reload.tags.size }.from(1).to(0)
    end

    it 'does not delete the tag' do
      expect { subject }.not_to change { site.reload.tags.size }
    end
  end
end
