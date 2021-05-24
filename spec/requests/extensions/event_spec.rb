# frozen_string_literal: true

require 'rails_helper'

site_events_query = <<-GRAPHQL
  query($id: ID!, $first: Int, $cursor: String) {
    site(id: $id) {
      recordings {
        items {
          id
          events(first: $first, cursor: $cursor) {
            items {
              ... on PageView {
                type
                locale
                useragent
                path
                time
                timestamp
              }
              ... on Scroll {
                type
                x
                y
                time
                timestamp
              }
              ... on Cursor {
                type
                x
                y
                time
                timestamp
              }
              ... on Interaction {
                type
                selector
                time
                timestamp
              }
            }
            pagination {
              cursor
              isLast
            }
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Types::EventExtension, type: :request do
  context 'when there are no events' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before { @recording = create_recording(site: site) }

    after { @recording.delete! }

    subject do
      variables = { id: site.id, first: 10 }
      graphql_request(site_events_query, variables, user)
    end

    it 'returns no items' do
      response = subject['data']['site']['recordings']['items'][0]['events']
      expect(response['items']).to eq []
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recordings']['items'][0]['events']
      expect(response['pagination']).to eq(
        {
          'cursor' => nil,
          'isLast' => true
        }
      )
    end
  end

  context 'when there are several events' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      @recording = create_recording(site: site)
      @events = 5.times.map { create_event(recording: @recording) }
    end

    after do
      @recording.delete!
      @events.each(&:delete!)
    end

    subject do
      variables = { id: site.id, first: 10 }
      graphql_request(site_events_query, variables, user)
    end

    it 'returns some items' do
      response = subject['data']['site']['recordings']['items'][0]['events']
      expect(response['items'].size).to eq 5
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recordings']['items'][0]['events']
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
      @recording = create_recording(site: site)
      @events = 15.times.map { create_event(recording: @recording) }

      variables = { id: site.id, first: 10, cursor: nil }
      response = graphql_request(site_events_query, variables, user)

      # Take the cursor from the first request and use it for
      # the second
      @cursor = response['data']['site']['recordings']['items'][0]['events']['pagination']['cursor']
      response
    end

    after do
      @recording.delete!
      @events.each(&:delete!)
    end

    subject do
      variables = { id: site.id, first: 10, cursor: @cursor }
      graphql_request(site_events_query, variables, user)
    end

    it 'returns the second set of results' do
      response = subject['data']['site']['recordings']['items'][0]['events']
      expect(response['items'].size).to eq 5
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recordings']['items'][0]['events']
      expect(response['pagination']['isLast']).to be true
      expect(response['pagination']['cursor']).to be nil
    end
  end
end
