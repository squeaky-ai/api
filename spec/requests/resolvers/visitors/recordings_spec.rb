# frozen_string_literal: true

require 'rails_helper'

visitor_recordings_query = <<-GRAPHQL
  query($site_id: ID!, $visitor_id: ID!, $page: Int, $sort: RecordingsSort) {
    site(siteId: $site_id) {
      visitor(visitorId: $visitor_id) {
        recordings(page: $page, size: 10, sort: $sort) {
          items {
            id
            duration
            viewed
            bookmarked
            startPage
            exitPage
            pageViews
            pageCount
            sessionId
            connectedAt
            disconnectedAt
          }
          pagination {
            pageSize
            total
            sort
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Visitors::Recordings, type: :request do
  context 'when there are no recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, visitor_id: 1 }
      graphql_request(visitor_recordings_query, variables, user)
    end

    it 'returns nil for the visitor' do
      response = subject['data']['site']['visitor']
      expect(response).to be nil
    end
  end

  context 'when there are some recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:visitor) { create_visitor }

    before do
      create_recording({ pages: [create_page(url: '/')] }, site: site, visitor: visitor, in_es: true)
      create_recording({ pages: [create_page(url: '/'), create_page(url: '/test')] }, site: site, visitor: visitor, in_es: true)
      create_recording({ pages: [create_page(url: '/contact')], deleted: true }, site: site, visitor: visitor, in_es: true)
      create_recording({ pages: [create_page(url: '/contact')] }, site: site, visitor: create_visitor, in_es: true)
    end

    subject do
      variables = { site_id: site.id, visitor_id: visitor.id }
      graphql_request(visitor_recordings_query, variables, user)
    end

    it 'returns the recordings for this visitor' do
      response = subject['data']['site']['visitor']['recordings']
      expect(response['items'].size).to eq 2
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['visitor']['recordings']
      expect(response['pagination']).to eq(
        'pageSize' => 10,
        'sort' => 'connected_at__desc',
        'total' => 2
      )
    end
  end
end