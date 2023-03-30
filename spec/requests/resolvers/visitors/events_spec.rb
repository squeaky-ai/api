# frozen_string_literal: true

require 'rails_helper'

visitor_events_query = <<-GRAPHQL
  query($site_id: ID!, $visitor_id: ID!, $page: Int, $size: Int, $sort: EventsFeedSort) {
    site(siteId: $site_id) {
      id
      visitor(visitorId: $visitor_id) {
        id
        events(page: $page, size: $size, sort: $sort) {
          items {
            id
            eventName
            timestamp
            source
            data
            recording {
              id
              sessionId
              bookmarked
            }
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

RSpec.describe Resolvers::Visitors::Events, type: :request do
  context 'when there are no events' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:visitor) { create(:visitor, site_id: site.id) }

    subject do
      variables = {
        site_id: site.id,
        visitor_id: visitor.id,
        page: 1,
        size: 10,
        sort: 'timestamp__desc'
      }
      graphql_request(visitor_events_query, variables, user)
    end

    it 'returns no items' do
      response = subject['data']['site']['visitor']['events']
      expect(response).to eq(
        'items' => [],
        'pagination' => {
          'pageSize' => 10,
          'total' => 0,
          'sort' => 'timestamp__desc'
        }
      )
    end
  end

  context 'when there are some events' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:visitor) { create(:visitor, site_id: site.id) }

    before do
      ClickHouse::CustomEvent.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          name: 'my-event',
          visitor_id: visitor.id,
          data: '{}',
          source: EventCapture::API,
          timestamp: 1675193201982
        }
      end
    end

    subject do
      variables = {
        site_id: site.id,
        visitor_id: visitor.id,
        page: 1,
        size: 10,
        sort: 'timestamp__desc'
      }
      graphql_request(visitor_events_query, variables, user)
    end

    it 'returns the items' do
      response = subject['data']['site']['visitor']['events']['items']
      expect(response).to match_array([
        {
          'data' => '{}',
          'eventName' => 'my-event',
          'id' => anything,
          'recording' => nil,
          'source' => EventCapture::API,
          'timestamp' => '2023-01-31T19:26:41Z'
        }
      ])
    end

    it 'returns the expected pagination' do
      response = subject['data']['site']['visitor']['events']['pagination']
      expect(response).to eq(
        'pageSize' => 10,
        'sort' => 'timestamp__desc',
        'total' => 1
      )
    end
  end
end
