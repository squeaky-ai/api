# frozen_string_literal: true

require 'rails_helper'

site_events_query = <<-GRAPHQL
  query($site_id: ID!, $recording_id: ID!, $first: Int, $cursor: String) {
    site(id: $site_id) {
      recording(id: $recording_id) {
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
            pageSize
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Types::EventsExtension, type: :request do
  context 'when there are no events' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before { @recording = create_recording(site: site) }

    after { @recording.delete! }

    subject do
      variables = { site_id: site.id, recording_id: @recording.session_id, first: 10 }
      graphql_request(site_events_query, variables, user)
    end

    it 'returns no items' do
      response = subject['data']['site']['recording']['events']
      expect(response['items']).to eq []
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recording']['events']
      expect(response['pagination']).to eq(
        {
          'cursor' => nil,
          'isLast' => true,
          'pageSize' => 10
        }
      )
    end
  end

  context 'when there are several events' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      @recording = create_recording(site: site)
      @events = create_events(count: 5, recording: @recording)
    end

    after do
      @recording.delete!
      @events.each(&:delete!)
    end

    subject do
      variables = { site_id: site.id, recording_id: @recording.session_id, first: 10 }
      graphql_request(site_events_query, variables, user)
    end

    it 'returns some items' do
      response = subject['data']['site']['recording']['events']
      expect(response['items'].size).to eq 5
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recording']['events']
      expect(response['pagination']).to eq(
        {
          'cursor' => nil,
          'isLast' => true,
          'pageSize' => 10
        }
      )
    end
  end

  context 'when limiting the results' do
    context 'when the number is below the minimum' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      before { @recording = create_recording(site: site) }

      after { @recording.delete! }

      subject do
        variables = { site_id: site.id, recording_id: @recording.session_id, first: -1 }
        graphql_request(site_events_query, variables, user)
      end

      it 'raises it to the minimum' do
        response = subject['data']['site']['recording']['events']
        expect(response['pagination']['pageSize']).to eq 1
      end
    end

    context 'when the number is above the maximum' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      before { @recording = create_recording(site: site) }

      after { @recording.delete! }

      subject do
        variables = { site_id: site.id, recording_id: @recording.session_id, first: 101 }
        graphql_request(site_events_query, variables, user)
      end

      it 'lowers it to the maximum' do
        response = subject['data']['site']['recording']['events']
        expect(response['pagination']['pageSize']).to eq 100
      end
    end
  end

  context 'when paginating' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:cursor) { nil }

    before do
      @recording = create_recording(site: site)
      @events = create_events(count: 15, recording: @recording)

      variables = { site_id: site.id, recording_id: @recording.session_id, first: 10, cursor: nil }
      response = graphql_request(site_events_query, variables, user)

      # Take the cursor from the first request and use it for
      # the second
      @cursor = response['data']['site']['recording']['events']['pagination']['cursor']
      response
    end

    after do
      @recording.delete!
      @events.each(&:delete!)
    end

    subject do
      variables = { site_id: site.id, recording_id: @recording.session_id, first: 10, cursor: @cursor }
      graphql_request(site_events_query, variables, user)
    end

    it 'returns the second set of results' do
      response = subject['data']['site']['recording']['events']
      expect(response['items'].size).to eq 5
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recording']['events']
      expect(response['pagination']).to eq(
        {
          'cursor' => nil,
          'isLast' => true,
          'pageSize' => 10
        }
      )
    end
  end
end
