# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

note_create_mutation = <<-GRAPHQL
  mutation($input: NotesCreateInput!) {
    noteCreate(input: $input) {
      id
      body
      timestamp
      user {
        firstName
        lastName
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Notes::Create, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:body) { 'Pimp my Ride' }
    let(:timestamp) { 2342342 }

    subject do
      variables = {
        input: {
          siteId: site.id,
          recordingId: SecureRandom.uuid,
          body: body,
          timestamp: timestamp
        }
      }
      graphql_request(note_create_mutation, variables, user)
    end

    it 'returns an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Recording not found'
    end
  end

  context 'when the recording exists' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site) }
    let(:body) { 'Beans on Toast' }
    let(:timestamp) { 3000 }

    subject do
      variables = {
        input: {
          siteId: site.id,
          recordingId: recording.id,
          body: body,
          timestamp: timestamp
        }
      }
      graphql_request(note_create_mutation, variables, user)
    end

    it 'returns the updated site' do
      notes = subject['data']['noteCreate']
      expect(notes['body']).to eq body
      expect(notes['timestamp']).to eq 3000
      expect(notes['user']['firstName']).to eq user.first_name
    end

    it 'creates the record' do
      expect { subject }.to change { recording.reload.notes.size }.from(0).to(1)
    end
  end
end
