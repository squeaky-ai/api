# frozen_string_literal: true

require 'rails_helper'

site_notes_query = <<-GRAPHQL
  query($site_id: ID!, $size: Int, $page: Int) {
    site(siteId: $site_id) {
      notes(size: $size, page: $page) {
        items {
          id
          timestamp
          body
          recordingId
          sessionId
          user {
            fullName
          }
        }
        pagination {
          pageSize
          total
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Notes::Notes, type: :request do
  context 'when there are no notes' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, size: 5, page: 1 }
      graphql_request(site_notes_query, variables, user)
    end

    it 'returns no items' do
      response = subject['data']['site']['notes']
      expect(response['items']).to eq []
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['notes']
      expect(response['pagination']).to eq(
        {
          'pageSize' => 5,
          'total' => 0
        }
      )
    end
  end

  context 'when there are several notes' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site) }

    subject do
      variables = { site_id: site.id, size: 5, page: 1 }
      graphql_request(site_notes_query, variables, user)
    end

    before do
      5.times { create(:note, recording_id: recording.id, user: user) }
    end

    it 'returns the items' do
      response = subject['data']['site']['notes']
      expect(response['items'].size).to eq 5
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['notes']
      expect(response['pagination']).to eq(
        {
          'pageSize' => 5,
          'total' => 5
        }
      )
    end
  end

  context 'when paginating' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site) }

    before do
      5.times { create(:note, recording_id: recording.id, user: user) }
    end

    subject do
      variables = { site_id: site.id, size: 2, page: 2 }
      graphql_request(site_notes_query, variables, user)
    end

    it 'returns the second set of results' do
      response = subject['data']['site']['notes']
      expect(response['items'].size).to eq 2
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['notes']
      expect(response['pagination']).to eq(
        {
          'pageSize' => 2,
          'total' => 5,
        }
      )
    end
  end

  context 'when the recording is soft deleted' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site, status: Recording::DELETED) }
    
    before do
      create(:note, recording_id: recording.id, user: user)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_notes_query, variables, user)
    end

    it 'does not return the note' do
      response = subject['data']['site']['notes']
      expect(response['items']).to eq([])
    end
  end
end
