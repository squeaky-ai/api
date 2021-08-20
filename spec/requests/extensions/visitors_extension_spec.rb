# frozen_string_literal: true

require 'rails_helper'

visitors_query = <<-GRAPHQL
  query($site_id: ID!, $page: Int, $size: Int, $query: String, $sort: VisitorSort) {
    site(siteId: $site_id) {
      visitors(page: $page, size: $size, query: $query, sort: $sort) {
        items {
          id
          recordingCount
          firstViewedAt
          lastActivityAt
          language
          viewportX
          viewportY
          deviceType
          browser
          browserString
        }
        pagination {
          pageSize
          total
          sort
        }
      }
    }
  }
GRAPHQL

RSpec.describe Types::VisitorsExtension, type: :request do
  context 'when there are no recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(visitors_query, variables, user)
    end

    it 'returns no items' do
      response = subject['data']['site']['visitors']
      expect(response['items']).to eq []
    end
  end

  context 'when there are some recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      visitor_1 = create_visitor
      visitor_2 = create_visitor
  
      create_recording({ connected_at: 1628405638578, disconnected_at: 1628405639578 }, site: site, visitor: visitor_1)
      create_recording({ connected_at: 1628405636578, disconnected_at: 1628405638578 }, site: site, visitor: visitor_1)
      create_recording({ connected_at: 1628405636578, disconnected_at: 1628405640578 }, site: site, visitor: visitor_2)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(visitors_query, variables, user)
    end

    it 'returns the visitors' do
      response = subject['data']['site']['visitors']
      expect(response['items'].size).to eq 2
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['visitors']
      expect(response['pagination']).to eq(
        'pageSize' => 15,
        'total' => 2,
        'sort' => 'RECORDINGS_COUNT_DESC'
      )
    end
  end
end
