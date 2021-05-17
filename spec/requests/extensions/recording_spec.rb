# frozen_string_literal: true

require 'rails_helper'

site_recordings_query = <<-GRAPHQL
  query($id: ID!, $query: String, $first: Int, $cursor: String) {
    site(id: $id) {
      recordings(query: $query, first: $first, cursor: $cursor) {
        items {
          id
          active
          viewerId
          sessionId
          locale
          duration
          pageCount
          startPage
          exitPage
          useragent
          viewportX
          viewportY
          createdAt
          updatedAt
        }
        pagination {
          cursor
          isLast
          total
        }
      }
    }
  }
GRAPHQL

RSpec.describe Types::RecordingExtension, type: :request do
  context 'when there are no recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { id: site.id, first: 10 }
      graphql_request(site_recordings_query, variables, user)
    end

    it 'returns no items' do
      response = subject['data']['site']['recordings']
      expect(response['items']).to eq []
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recordings']
      expect(response['pagination']).to eq(
        {
          'cursor' => nil,
          'total' => 0,
          'isLast' => true
        }
      )
    end
  end

  context 'when there are several recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { id: site.id, first: 10 }
      graphql_request(site_recordings_query, variables, user)
    end

    before { 5.times { create_recording(site: site) } }

    it 'returns no items' do
      response = subject['data']['site']['recordings']
      expect(response['items'].size).to eq 5
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recordings']
      expect(response['pagination']).to eq(
        {
          'cursor' => nil,
          'total' => 5,
          'isLast' => true
        }
      )
    end
  end

  context 'when paginating' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before { 15.times { create_recording(site: site) } }

    context 'when the first request is made' do
      subject do
        variables = { id: site.id, first: 10, cursor: nil }
        graphql_request(site_recordings_query, variables, user)
      end

      it 'returns the first set of results' do
        response = subject['data']['site']['recordings']
        expect(response['items'].size).to eq 10
      end

      it 'returns the correct pagination' do
        response = subject['data']['site']['recordings']
        expect(response['pagination']['total']).to eq 15
        expect(response['pagination']['isLast']).to be false
        expect(response['pagination']['cursor']).not_to be nil
      end
    end

    context 'when the second request is made' do
      subject do
        variables = { id: site.id, first: 10, cursor: 'eyJwYWdlIjoyfQ==' }
        graphql_request(site_recordings_query, variables, user)
      end

      it 'returns the second set of results' do
        response = subject['data']['site']['recordings']
        expect(response['items'].size).to eq 5
      end

      it 'returns the correct pagination' do
        response = subject['data']['site']['recordings']
        expect(response['pagination']['total']).to eq 15
        expect(response['pagination']['isLast']).to be true
        expect(response['pagination']['cursor']).to be nil
      end
    end
  end
end
