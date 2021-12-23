# frozen_string_literal: true

require 'rails_helper'

visitor_pages_query = <<-GRAPHQL
  query($site_id: ID!, $visitor_id: ID!, $page: Int, $sort: VisitorsPagesSort) {
    site(siteId: $site_id) {
      visitor(visitorId: $visitor_id) {
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

RSpec.describe Resolvers::Visitors::Pages, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, visitor_id: 1 }
      graphql_request(visitor_pages_query, variables, user)
    end

    it 'returns nil for the visitor' do
      response = subject['data']['site']['visitor']
      expect(response).to be nil
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create_site_and_team(user: user) }
    let(:visitor) { create_visitor }

    before do
      create_recording({ pages: [create_page(url: '/')] }, site: site, visitor: visitor)
      create_recording({ pages: [create_page(url: '/'), create_page(url: '/test')] }, site: site, visitor: visitor)
      create_recording({ pages: [create_page(url: '/contact')] }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, visitor_id: visitor.id }
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
        'sort' => 'views_count__desc',
        'total' => 2
      )
    end
  end
end
