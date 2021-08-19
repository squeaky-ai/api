# frozen_string_literal: true

require 'rails_helper'

visitor_recordings_query = <<-GRAPHQL
  query($site_id: ID!, $visitor_id: ID!, $page: Int, $sort: RecordingSort) {
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

RSpec.describe Types::VisitorRecordingsExtension, type: :request do
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
      create_recording({ page_views: ['/'] }, site: site, visitor: visitor)
      create_recording({ page_views: ['/', '/test'] }, site: site, visitor: visitor)
      create_recording({ page_views: ['/contact'], deleted: true }, site: site, visitor: visitor)
      create_recording({ page_views: ['/contact'] }, site: site, visitor: create_visitor)
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
        'sort' => 'DATE_DESC',
        'total' => 2
      )
    end
  end
end
