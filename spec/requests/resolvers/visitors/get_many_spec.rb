# frozen_string_literal: true

require 'rails_helper'

visitors_query = <<-GRAPHQL
  query($site_id: ID!, $page: Int, $size: Int, $sort: VisitorsSort) {
    site(siteId: $site_id) {
      visitors(page: $page, size: $size, sort: $sort) {
        items {
          id
          recordingCount {
            total
            new
          }
          firstViewedAt
          lastActivityAt
          language
          devices {
            viewportX
            viewportY
            deviceX
            deviceY
            deviceType
            browserName
            browserDetails
          }
          linkedData
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

RSpec.describe Resolvers::Visitors::GetMany, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

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
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      visitor_1 = create(:visitor)
      visitor_2 = create(:visitor)
  
      create(:recording, connected_at: 1628405638578, disconnected_at: 1628405639578, site: site, visitor: visitor_1)
      create(:recording, connected_at: 1628405636578, disconnected_at: 1628405638578, site: site, visitor: visitor_1)
      create(:recording, connected_at: 1628405636578, disconnected_at: 1628405640578, site: site, visitor: visitor_2)
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
        'pageSize' => 25,
        'total' => 2,
        'sort' => 'last_activity_at__desc'
      )
    end
  end

  context 'when the recordings are deleted' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      visitor = create(:visitor)
  
      create(:recording, connected_at: 1628405638578, disconnected_at: 1628405639578, site: site, visitor: visitor)
      create(:recording, connected_at: 1628405636578, disconnected_at: 1628405638578, status: Recording::DELETED, site: site, visitor: visitor)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(visitors_query, variables, user)
    end

    it 'returns the count that excludes deleted recordings' do
      response = subject['data']['site']['visitors']
      expect(response['items'][0]['recordingCount']['total']).to eq 1
    end
  end

  context 'when there are no external attributes' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      visitor = create(:visitor)

      create(:recording, connected_at: 1628405638578, disconnected_at: 1628405639578, site: site, visitor: visitor)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(visitors_query, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['site']['visitors']
      expect(response['items'][0]['linkedData']).to eq nil
    end
  end

  context 'when there are some external attributes' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:external_attributes) { { name: 'Bob Dylan', email: 'bobby_d@gmail.com' } }

    before do
      visitor = create(:visitor, external_attributes: external_attributes)

      create(:recording, connected_at: 1628405638578, disconnected_at: 1628405639578, site: site, visitor: visitor)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(visitors_query, variables, user)
    end

    it 'returns the attributes' do
      response = subject['data']['site']['visitors']
      expect(response['items'][0]['linkedData']).to eq external_attributes.to_json
    end
  end
end
