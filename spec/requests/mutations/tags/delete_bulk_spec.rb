# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

tags_delete_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $tag_ids: [ID!]!) {
    tagsDelete(input: { siteId: $site_id, tagIds: $tag_ids }) {
      id
      name
    }
  }
GRAPHQL

RSpec.describe Mutations::Tags::DeleteBulk, type: :request do
  context 'when none of the tags exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, tag_ids: [234234] }
      graphql_request(tags_delete_mutation, variables, user)
    end

    it 'returns the unmodified site' do
      tags = subject['data']['tagsDelete']
      expect(tags.size).to eq 0
    end
  end

  context 'when one of the tags exists' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:tag) { Tag.create(name: 'Foo', site_id: site.id) }

    before { tag }

    subject do
      variables = { site_id: site.id, tag_ids: [tag.id, 23423423] }
      graphql_request(tags_delete_mutation, variables, user)
    end

    it 'returns the updated site' do
      tags = subject['data']['tagsDelete']
      expect(tags.size).to eq 0
    end

    it 'deletes the tag' do
      expect { subject }.to change { site.reload.tags.size }.from(1).to(0)
    end
  end

  context 'when multiple tags exists' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:tag_1) { Tag.create(name: 'Foo', site_id: site.id) }
    let(:tag_2) { Tag.create(name: 'Bar', site_id: site.id) }

    before do
      tag_1
      tag_2
    end

    subject do
      variables = { site_id: site.id, tag_ids: [tag_1.id, tag_2.id] }
      graphql_request(tags_delete_mutation, variables, user)
    end

    it 'returns the updated site' do
      tags = subject['data']['tagsDelete']
      expect(tags.size).to eq 0
    end

    it 'deletes the tag' do
      expect { subject }.to change { site.reload.tags.size }.from(2).to(0)
    end
  end
end
