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
              mouseX
              mouseY
              scrollX
              scrollY
              position
            }
            pagination {
              cursor
              isLast
              total
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

    before { create_recording(site: site) }

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
          'total' => 0,
          'isLast' => true
        }
      )
    end
  end

  context 'when there are several events' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      recording = create_recording(site: site)
      5.times { create_event(recording: recording) }
    end

    subject do
      variables = { id: site.id, first: 10 }
      graphql_request(site_events_query, variables, user)
    end

    it 'returns no items' do
      response = subject['data']['site']['recordings']['items'][0]['events']
      expect(response['items'].size).to eq 5
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recordings']['items'][0]['events']
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

    before do
      recording = create_recording(site: site)
      15.times { create_event(recording: recording) }
    end

    context 'when the first request is made' do
      subject do
        variables = { id: site.id, first: 10 }
        graphql_request(site_events_query, variables, user)
      end

      it 'returns the first set of results' do
        response = subject['data']['site']['recordings']['items'][0]['events']
        expect(response['items'].size).to eq 10
      end

      it 'returns the correct pagination' do
        response = subject['data']['site']['recordings']['items'][0]['events']
        expect(response['pagination']['total']).to eq 15
        expect(response['pagination']['isLast']).to be false
        expect(response['pagination']['cursor']).not_to be nil
      end
    end

    context 'when the second request is made' do
      subject do
        variables = { id: site.id, first: 10, cursor: 'eyJvZmZzZXQiOjEwfQ==' }
        graphql_request(site_events_query, variables, user)
      end

      it 'returns the second set of results' do
        response = subject['data']['site']['recordings']['items'][0]['events']
        expect(response['items'].size).to eq 5
      end

      it 'returns the correct pagination' do
        response = subject['data']['site']['recordings']['items'][0]['events']
        expect(response['pagination']['total']).to eq 15
        expect(response['pagination']['isLast']).to be true
        expect(response['pagination']['cursor']).to be nil
      end
    end
  end
end
