# frozen_string_literal: true

require 'rails_helper'

tag_update_mutation = <<-GRAPHQL
  mutation($input: TagsUpdateInput!) {
    tagUpdate(input: $input) {
      id
      name
    }
  }
GRAPHQL

RSpec.describe Mutations::Tags::Update, type: :request do
  context 'when the tag does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site) }
    let(:name) { 'Teapot' }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          tagId: 345345345, 
          name:
        }
      }
      graphql_request(tag_update_mutation, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['tagUpdate']
      expect(response).to eq nil
    end

    it 'does not upsert a tag' do
      expect { subject }.not_to change { recording.reload.tags.size }
    end
  end

  context 'when the tag exists' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site) }
    let(:tag) { create(:tag, site_id: site.id) }
    let(:name) { 'Saucepan' }

    before do
      recording.tags << tag
      recording.save
    end

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          tagId: tag.id.to_s, 
          name:
        }
      }
      graphql_request(tag_update_mutation, variables, user)
    end

    it 'returns the updated tag' do
      tags = subject['data']['tagUpdate']
      expect(tags['name']).to eq name
    end

    it 'updates the record' do
      expect { subject }.to change { recording.reload.tags[0].name }.from(tag.name).to(name)
    end
  end
end
