# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

tag_delete_mutation = <<-GRAPHQL
  mutation($input: TagsDeleteInput!) {
    tagDelete(input: $input) {
      id
      name
    }
  }
GRAPHQL

RSpec.describe Mutations::Tags::Delete, type: :request do
  context 'when the tag does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          tagId: 23423423 
        }
      }
      graphql_request(tag_delete_mutation, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['tagDelete']
      expect(response).to eq nil
    end
  end

  context 'when the tag exists' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:tag) { Tag.create(name: 'Foo', site_id: site.id) }

    before { tag }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          tagId: tag.id.to_s 
        }
      }
      graphql_request(tag_delete_mutation, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['tagDelete']
      expect(response).to eq nil
    end

    it 'deletes the tag' do
      expect { subject }.to change { site.reload.tags.size }.from(1).to(0)
    end
  end

  context 'when a tag exists and is joined to a recording' do
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
          tagId: tag.id.to_s 
        }
      }
      graphql_request(tag_delete_mutation, variables, user)
    end

    it 'deletes the tag' do
      expect { subject }.to change { site.reload.tags.size }.from(1).to(0)
    end

    it 'deletes the join' do
      expect { subject }.to change { recording.reload.tags.size }.from(1).to(0)
    end
  end
end
