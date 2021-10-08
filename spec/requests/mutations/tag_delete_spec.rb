# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

tag_delete_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $tag_id: ID!) {
    tagDelete(input: { siteId: $site_id, tagId: $tag_id }) {
      id
      tags {
        id
        name
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::TagDelete, type: :request do
  context 'when the tag does not exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, tag_id: Faker::Number.rand.to_s }
      graphql_request(tag_delete_mutation, variables, user)
    end

    it 'returns the unmodified site' do
      tags = subject['data']['tagDelete']['tags']
      expect(tags.size).to eq 0
    end
  end

  context 'when the tag exists' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:tag) { Tag.create(name: 'Foo', site_id: site.id) }

    before { tag }

    subject do
      variables = { site_id: site.id, tag_id: tag.id.to_s }
      graphql_request(tag_delete_mutation, variables, user)
    end

    it 'returns the updated site' do
      tags = subject['data']['tagDelete']['tags']
      expect(tags.size).to eq 0
    end

    it 'deletes the tag' do
      expect { subject }.to change { site.reload.tags.size }.from(1).to(0)
    end
  end

  context 'when a tag exists and is joined to a recording' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:recording) { create_recording(site: site, visitor: create_visitor) }
    let(:tag) { create_tag(recording: recording, site: site) }

    before { tag }

    subject do
      variables = { site_id: site.id, tag_id: tag.id.to_s }
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
