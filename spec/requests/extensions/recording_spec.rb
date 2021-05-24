# frozen_string_literal: true

require 'rails_helper'

site_recordings_query = <<-GRAPHQL
  query($id: ID!, $first: Int, $cursor: String) {
    site(id: $id) {
      recordings(first: $first, cursor: $cursor) {
        items {
          id
          siteId
          viewerId
          active
          locale
          duration
          pageCount
          startPage
          exitPage
          useragent
          viewportX
          viewportY
          connectedAt
          disconnectedAt
        }
        pagination {
          cursor
          isLast
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

    before do
      @recordings = 5.times.map { create_recording(site: site) }
    end

    after { @recordings.each(&:delete!) }

    it 'returns the items' do
      response = subject['data']['site']['recordings']
      expect(response['items'].size).to eq 5
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recordings']
      expect(response['pagination']).to eq(
        {
          'cursor' => nil,
          'isLast' => true
        }
      )
    end
  end

  context 'when paginating' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:cursor) { nil }

    before do
      @recordings = 15.times.map { create_recording(site: site) }

      variables = { id: site.id, first: 10, cursor: nil }
      response = graphql_request(site_recordings_query, variables, user)

      # Take the cursor from the first request and use it for
      # the second
      @cursor = response['data']['site']['recordings']['pagination']['cursor']
      response
    end

    after { @recordings.each(&:delete!) }

    subject do
      variables = { id: site.id, first: 10, cursor: @cursor }
      graphql_request(site_recordings_query, variables, user)
    end

    it 'returns the second set of results' do
      response = subject['data']['site']['recordings']
      expect(response['items'].size).to eq 5
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recordings']
      expect(response['pagination']['isLast']).to be true
      expect(response['pagination']['cursor']).to be nil
    end
  end
end
