# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

note_update_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $session_id: ID!, $note_id: ID!, $body: String, $timestamp: Int) {
    noteUpdate(input: { siteId: $site_id, sessionId: $session_id, noteId: $note_id, body: $body, timestamp: $timestamp }) {
      id
      recording(id: $session_id) {
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

RSpec.describe Mutations::NoteUpdate, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = {
        site_id: site.id,
        session_id: SecureRandom.uuid,
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
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:recording) { create_recording(site: site) }

    subject do
      variables = {
        site_id: site.id,
        session_id: recording.session_id,
        note_id: SecureRandom.uuid
      }
      graphql_request(note_update_mutation, variables, user)
    end

    it 'returns the unmodified site' do
      notes = subject['data']['noteUpdate']['recording']['notes']
      expect(notes.size).to eq 0
    end

    it 'does not delete anything' do
      expect { subject }.not_to change { recording.reload.notes.size }
    end
  end

  context 'when the note exists' do
    context 'and the user is a member' do
      context 'and they are deleting their own note' do
        let(:user) { create_user }
        let(:site) { create_site_and_team(user: create_user) }
        let(:team) { create_team(site: site, user: user, role: Team::MEMBER) }
        let(:recording) { create_recording(site: site) }
        let(:body) { Faker::Lorem.sentence }
        let(:note) { create_note(recording: recording, user: user) }
  
        before do
          note
          team
        end
  
        subject do
          variables = {
            site_id: site.id,
            session_id: recording.session_id,
            note_id: note.id.to_s,
            body: body
          }
          graphql_request(note_update_mutation, variables, user)
        end
  
        it 'returns the modified site' do
          notes = subject['data']['noteUpdate']['recording']['notes']
          expect(notes[0]['body']).to eq body
        end
  
        it 'updates the note' do
          expect { subject }.to change { recording.reload.notes[0].body }.from(note.body).to(body)
        end
      end

      context 'and they are deleting someone elses note' do
        let(:user) { create_user }
        let(:site) { create_site_and_team(user: create_user) }
        let(:team) { create_team(site: site, user: user, role: Team::MEMBER) }
        let(:recording) { create_recording(site: site) }
        let(:body) { Faker::Lorem.sentence }
        let(:note) { create_note(recording: recording, user: create_user) }
  
        before do
          note
          team
        end
  
        subject do
          variables = {
            site_id: site.id,
            session_id: recording.session_id,
            note_id: note.id.to_s,
            body: body
          }
          graphql_request(note_update_mutation, variables, user)
        end
  
        it 'returns the unmodified site' do
          notes = subject['data']['noteUpdate']['recording']['notes']
          expect(notes[0]['body']).to eq note.body
        end
  
        it 'does not update the note' do
          expect { subject }.not_to change { recording.reload.notes[0].body }
        end
      end
    end

    context 'and the user is an admin' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user, role: Team::ADMIN) }
      let(:recording) { create_recording(site: site) }
      let(:note) { create_note(recording: recording, user: create_user) }
      let(:body) { Faker::Lorem.sentence }

      before { note }

      subject do
        variables = {
          site_id: site.id,
          session_id: recording.session_id,
          note_id: note.id.to_s,
          body: body
        }
        graphql_request(note_update_mutation, variables, user)
      end

      it 'returns the modified site' do
        notes = subject['data']['noteUpdate']['recording']['notes']
        expect(notes[0]['body']).to eq body
      end

      it 'updates the note' do
        expect { subject }.to change { recording.reload.notes[0].body }.from(note.body).to(body)
      end
    end

    context 'and the user is the owner' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user, role: Team::OWNER) }
      let(:recording) { create_recording(site: site) }
      let(:note) { create_note(recording: recording, user: create_user) }
      let(:body) { Faker::Lorem.sentence }

      before { note }

      subject do
        variables = {
          site_id: site.id,
          session_id: recording.session_id,
          note_id: note.id.to_s,
          body: body
        }
        graphql_request(note_update_mutation, variables, user)
      end

      it 'returns the modified site' do
        notes = subject['data']['noteUpdate']['recording']['notes']
        expect(notes[0]['body']).to eq body
      end

      it 'updates the note' do
        expect { subject }.to change { recording.reload.notes[0].body }.from(note.body).to(body)
      end
    end
  end
end