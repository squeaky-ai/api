# frozen_string_literal: true

require 'rails_helper'

visitors_query = <<-GRAPHQL
  query($site_id: ID!, $page: Int, $size: Int, $query: String, $sort: VisitorSort) {
    site(siteId: $site_id) {
      visitors(page: $page, size: $size, query: $query, sort: $sort) {
        items {
          id
          recordingsCount {
            total
            new
          }
          firstViewedAt
          lastActivityAt
          language
          devices {
            viewportX
            viewportY
            deviceType
            browserName
            browserDetails
          }
          attributes
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
        'sort' => 'views_count__desc'
      )
    end
  end

  context 'when the recordings are deleted' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      visitor = create_visitor
  
      create_recording({ connected_at: 1628405638578, disconnected_at: 1628405639578 }, site: site, visitor: visitor)
      create_recording({ connected_at: 1628405636578, disconnected_at: 1628405638578, deleted: true }, site: site, visitor: visitor)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(visitors_query, variables, user)
    end

    it 'returns the count that excludes deleted recordings' do
      response = subject['data']['site']['visitors']
      expect(response['items'][0]['recordingsCount']['total']).to eq 1
      expect(response['items'][0]['recordingsCount']['new']).to eq 1
    end
  end

  context 'when there are no external attributes' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ connected_at: 1628405638578, disconnected_at: 1628405639578 }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(visitors_query, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['site']['visitors']
      expect(response['items'][0]['attributes']).to be nil
    end
  end

  context 'when there are some external attributes' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:external_attributes) { { name: 'Bob Dylan', email: 'bobby_d@gmail.com' } }

    before do
      visitor = create_visitor(external_attributes: external_attributes)
      create_recording({ connected_at: 1628405638578, disconnected_at: 1628405639578 }, site: site, visitor: visitor)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(visitors_query, variables, user)
    end

    it 'returns the attributes' do
      response = subject['data']['site']['visitors']
      expect(response['items'][0]['attributes']).to eq external_attributes.to_json
    end
  end
end
