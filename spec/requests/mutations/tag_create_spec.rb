# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

tag_create_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $session_id: ID!, $name: String!) {
    tagCreate(input: { siteId: $site_id, sessionId: $session_id, name: $name }) {
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

RSpec.describe Mutations::TagCreate, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:name) { Faker::Book.title }

    subject do
      variables = { site_id: site.id, session_id: SecureRandom.uuid, name: name }
      graphql_request(tag_create_mutation, variables, user)
    end

    it 'returns an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Recording not found'
    end
  end

  context 'when the recording exists' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:recording) { create_recording(site: site) }
    let(:name) { Faker::Book.title }

    subject do
      variables = { site_id: site.id, session_id: recording.session_id, name: name }
      graphql_request(tag_create_mutation, variables, user)
    end

    it 'returns the updated site' do
      tags = subject['data']['tagCreate']['recording']['tags']
      expect(tags.size).to eq 1
      expect(tags[0]['name']).to eq name
    end

    it 'creates the record' do
      expect { subject }.to change { recording.reload.tags.size }.from(0).to(1)
    end
  end
end