# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

tags_merge_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $tag_ids: [ID!]!, $name: String!) {
    tagsMerge(input: { siteId: $site_id, tagIds: $tag_ids, name: $name }) {
      id
      tags {
        id
        name
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::TagsMerge, type: :request do
  context 'when none of the tags exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, tag_ids: [Faker::Number.rand.to_s], name: 'Foo' }
      graphql_request(tags_merge_mutation, variables, user)
    end

    it 'returns the unmodified site' do
      tags = subject['data']['tagsMerge']['tags']
      expect(tags.size).to eq 0
    end
  end

  context 'when one of the tags exists' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:tag) { Tag.create(name: 'Teapot', site_id: site.id) }

    before { tag }

    subject do
      variables = { site_id: site.id, tag_ids: [tag.id, Faker::Number.rand.to_s], name: 'Foo' }
      graphql_request(tags_merge_mutation, variables, user)
    end

    it 'returns the updated site' do
      tags = subject['data']['tagsMerge']['tags']
      expect(tags.size).to eq 1
      expect(tags[0]['name']).to eq 'Foo'
    end

    it 'updates the tags' do
      expect { subject }.to change { site.reload.tags[0].name }.from('Teapot').to('Foo')
    end
  end

  context 'when multiple tags exists' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:tag_1) { Tag.create(name: 'Bar', site_id: site.id) }
    let(:tag_2) { Tag.create(name: 'Baz', site_id: site.id) }

    before do
      tag_1
      tag_2
    end

    subject do
      variables = { site_id: site.id, tag_ids: [tag_1.id, tag_2.id], name: 'Foo' }
      graphql_request(tags_merge_mutation, variables, user)
    end

    it 'returns the updated site' do
      tags = subject['data']['tagsMerge']['tags']
      expect(tags.size).to eq 1
      expect(tags[0]['name']).to eq 'Foo'
    end

    it 'updates the tags' do
      subject
      expect(site.reload.tags.size).to eq 1
      expect(site.reload.tags.map(&:name).uniq).to eq (['Foo'])
    end
  end
end