# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

note_update_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $recording_id: ID!, $note_id: ID!, $body: String, $timestamp: Int) {
    noteUpdate(input: { siteId: $site_id, recordingId: $recording_id, noteId: $note_id, body: $body, timestamp: $timestamp }) {
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

RSpec.describe Mutations::Notes::Update, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        site_id: site.id,
        recording_id: SecureRandom.uuid,
        note_id: SecureRandom.uuid
      }
      graphql_request(note_update_mutation, variables, user)
    end

    it 'returns an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Recording not found'
    end
  end

  context 'when the note does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site) }

    subject do
      variables = {
        site_id: site.id,
        recording_id: recording.id,
        note_id: SecureRandom.uuid
      }
      graphql_request(note_update_mutation, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['noteUpdate']
      expect(response).to eq nil
    end

    it 'does not delete anything' do
      expect { subject }.not_to change { recording.reload.notes.size }
    end
  end

  context 'when the note exists' do
    context 'and the user is a member' do
      context 'and they are deleting their own note' do
        let(:user) { create(:user) }
        let(:site) { create(:site_with_team) }
        let(:team) { create(:team, site: site, user: user, role: Team::MEMBER) }
        let(:recording) { create(:recording, site: site) }
        let(:body) { 'Toad' }
        let(:note) { create(:note, recording_id: recording.id, user: user) }
  
        before do
          note
          team
        end
  
        subject do
          variables = {
            site_id: site.id,
            recording_id: recording.id,
            note_id: note.id.to_s,
            body: body
          }
          graphql_request(note_update_mutation, variables, user)
        end
  
        it 'returns the note' do
          response = subject['data']['noteUpdate']
          expect(response['body']).to eq body
        end
  
        it 'updates the note' do
          expect { subject }.to change { recording.reload.notes[0].body }.from(note.body).to(body)
        end
      end

      context 'and they are deleting someone elses note' do
        let(:user) { create(:user) }
        let(:site) { create(:site_with_team) }
        let(:team) { create(:team, site: site, user: user, role: Team::MEMBER) }
        let(:recording) { create(:recording, site: site) }
        let(:body) { 'Princess Peach' }
        let(:note) { create(:note, recording_id: recording.id) }
  
        before do
          note
          team
        end
  
        subject do
          variables = {
            site_id: site.id,
            recording_id: recording.id,
            note_id: note.id.to_s,
            body: body
          }
          graphql_request(note_update_mutation, variables, user)
        end
  
        it 'returns the unmodified note' do
          response = subject['data']['noteUpdate']
          expect(response['body']).to eq note.body
        end
  
        it 'does not update the note' do
          expect { subject }.not_to change { recording.reload.notes[0].body }
        end
      end
    end

    context 'and the user is an admin' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team) }
      let(:recording) { create(:recording, site: site) }
      let(:note) { create(:note, recording_id: recording.id) }
      let(:body) { 'Bowser' }
      
      before do
        note
        create(:team, user: user, site: site, role: Team::ADMIN)
      end

      subject do
        variables = {
          site_id: site.id,
          recording_id: recording.id,
          note_id: note.id.to_s,
          body: body
        }
        graphql_request(note_update_mutation, variables, user)
      end

      it 'returns the modified note' do
        response = subject['data']['noteUpdate']
        expect(response['body']).to eq body
      end

      it 'updates the note' do
        expect { subject }.to change { recording.reload.notes[0].body }.from(note.body).to(body)
      end
    end

    context 'and the user is the owner' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
      let(:recording) { create(:recording, site: site) }
      let(:note) { create(:note, recording_id: recording.id) }
      let(:body) { 'Kooper Trooper' }

      before { note }

      subject do
        variables = {
          site_id: site.id,
          recording_id: recording.id,
          note_id: note.id.to_s,
          body: body
        }
        graphql_request(note_update_mutation, variables, user)
      end

      it 'returns the modified note' do
        response = subject['data']['noteUpdate']
        expect(response['body']).to eq body
      end

      it 'updates the note' do
        expect { subject }.to change { recording.reload.notes[0].body }.from(note.body).to(body)
      end
    end
  end
end
