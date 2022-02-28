# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

note_delete_mutation = <<-GRAPHQL
  mutation($input: NotesDeleteInput!) {
    noteDelete(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Notes::Delete, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        input: {
          siteId: site.id,
          recordingId: SecureRandom.uuid,
          noteId: SecureRandom.uuid
        }
      }
      graphql_request(note_delete_mutation, variables, user)
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
        input: {
          siteId: site.id,
          recordingId: recording.id,
          noteId: SecureRandom.uuid
        }
      }
      graphql_request(note_delete_mutation, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['noteDelete']
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
        let(:note) { create(:note, recording_id: recording.id, user: user) }
  
        before do
          note
          team
        end
  
        subject do
          variables = {
            input: {
              siteId: site.id,
              recordingId: recording.id,
              noteId: note.id.to_s
            }
          }
          graphql_request(note_delete_mutation, variables, user)
        end
  
        it 'returns nil' do
          response = subject['data']['noteDelete']
          expect(response).to eq nil
        end
  
        it 'deletes the note' do
          expect { subject }.to change { recording.reload.notes.size }.from(1).to(0)
        end
      end

      context 'and they are deleting someone elses note' do
        let(:user) { create(:user) }
        let(:site) { create(:site_with_team) }
        let(:team) { create(:team, site: site, user: user, role: Team::MEMBER) }
        let(:recording) { create(:recording, site: site) }
        let(:note) { create(:note, recording_id: recording.id) }
  
        before do
          note
          team
        end
  
        subject do
          variables = {
            input: {
              siteId: site.id,
              recordingId: recording.id,
              noteId: note.id.to_s
            }
          }
          graphql_request(note_delete_mutation, variables, user)
        end
  
        it 'returns the unmodified note' do
          response = subject['data']['noteDelete']
          expect(response).not_to eq nil
        end
  
        it 'does not delete the note' do
          expect { subject }.not_to change { recording.reload.notes.size }
        end
      end
    end

    context 'and the user is an admin' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team) }
      let(:recording) { create(:recording, site: site) }
      let(:note) { create(:note, recording_id: recording.id) }

      before do
        note
        create(:team, user: user, site: site, role: Team::ADMIN)
      end

      subject do
        variables = {
          input: {
            siteId: site.id,
            recordingId: recording.id,
            noteId: note.id.to_s
          }
        }
        graphql_request(note_delete_mutation, variables, user)
      end

      it 'returns nil' do
        response = subject['data']['noteDelete']
        expect(response).to eq nil
      end

      it 'deletes the note' do
        expect { subject }.to change { recording.reload.notes.size }.from(1).to(0)
      end
    end

    context 'and the user is the owner' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
      let(:recording) { create(:recording, site: site) }
      let(:note) { create(:note, recording_id: recording.id) }

      before { note }

      subject do
        variables = {
          input: {
            siteId: site.id,
            recordingId: recording.id,
            noteId: note.id.to_s
          }
        }
        graphql_request(note_delete_mutation, variables, user)
      end

      it 'returns nil' do
        response = subject['data']['noteDelete']
        expect(response).to eq nil
      end

      it 'deletes the note' do
        expect { subject }.to change { recording.reload.notes.size }.from(1).to(0)
      end
    end
  end
end
