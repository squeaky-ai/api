# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

note_create_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $recording_id: ID!, $body: String!, $timestamp: Int) {
    noteCreate(input: { siteId: $site_id, recordingId: $recording_id, body: $body, timestamp: $timestamp }) {
      id
      recording(recordingId: $recording_id) {
        notes {
          id
          body
          timestamp
          user {
            firstName
            lastName
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Notes::Create, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:body) { Faker::Book.title }
    let(:timestamp) { Faker::Number.number(digits: 5) }

    subject do
      variables = {
        site_id: site.id,
        recording_id: SecureRandom.uuid,
        body: body,
        timestamp: timestamp
      }
      graphql_request(note_create_mutation, variables, user)
    end

    it 'returns an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Recording not found'
    end
  end

  context 'when the recording exists' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:recording) { create_recording(site: site, visitor: create_visitor) }
    let(:body) { Faker::Book.title }
    let(:timestamp) { 3000 }

    subject do
      variables = {
        site_id: site.id,
        recording_id: recording.id,
        body: body,
        timestamp: timestamp
      }
      graphql_request(note_create_mutation, variables, user)
    end

    it 'returns the updated site' do
      notes = subject['data']['noteCreate']['recording']['notes']
      expect(notes.size).to eq 1
      expect(notes[0]['body']).to eq body
      expect(notes[0]['timestamp']).to eq 3000
      expect(notes[0]['user']['firstName']).to eq user.first_name
    end

    it 'creates the record' do
      expect { subject }.to change { recording.reload.notes.size }.from(0).to(1)
    end
  end
end
