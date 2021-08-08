# frozen_string_literal: true

require 'rails_helper'

visitor_pages_query = <<-GRAPHQL
  query($site_id: ID!, $viewer_id: ID!, $page: Int, $sort: VisitorPagesSort) {
    site(siteId: $site_id) {
      visitor(viewerId: $viewer_id) {
        pages(page: $page, size: 10, sort: $sort) {
          items {
            pageView
            pageViewCount
            averageTimeOnPage
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

RSpec.describe Types::VisitorPagesExtension, type: :request do
  context 'when there are no recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:viewer_id) { 'aaaaaaa' }

    subject do
      variables = { site_id: site.id, viewer_id: viewer_id }
      graphql_request(visitor_pages_query, variables, user)
    end

    it 'returns nil for the visitor' do
      response = subject['data']['site']['visitor']
      expect(response).to be nil
    end
  end

  context 'when there are some recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:viewer_id) { 'aaaaaaa' }

    before do
      create_recording({ viewer_id: viewer_id, page_views: ['/'] }, site: site)
      create_recording({ viewer_id: viewer_id, page_views: ['/', '/test'] }, site: site)
      create_recording({ viewer_id: 'bbbbbbb', page_views: ['/contact'] }, site: site)
    end

    subject do
      variables = { site_id: site.id, viewer_id: viewer_id }
      graphql_request(visitor_pages_query, variables, user)
    end

    it 'returns the pages for this visitor' do
      response = subject['data']['site']['visitor']['pages']
      expect(response['items'].size).to eq 2
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['visitor']['pages']
      expect(response['pagination']).to eq(
        'pageSize' => 10,
        'sort' => 'VIEWS_COUNT_DESC',
        'total' => 2
      )
    end
  end
end
