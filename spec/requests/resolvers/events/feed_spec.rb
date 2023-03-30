# frozen_string_literal: true

require 'rails_helper'

event_feed_query = <<-GRAPHQL
  query($site_id: ID!, $page: Int, $size: Int, $sort: EventsFeedSort, $capture_ids: [ID!]!, $group_ids: [ID!]!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      id      
      eventFeed(captureIds: $capture_ids, groupIds: $group_ids, page: $page, size: $size, sort: $sort, fromDate: $from_date, toDate: $to_date) {
        items {
          id
          eventName
          timestamp
          source
          data
          visitor {
            id
            visitorId
            starred
          }
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
GRAPHQL

RSpec.describe Resolvers::Events::Feed, type: :request do
  context 'when there is no data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:rule) { { matcher: 'equals', condition: 'or', value: 'my-event' } }
    let(:event_capture) { create(:event_capture, site:, event_type: EventCapture::CUSTOM, rules: [rule]) }

    subject do
      variables = {
        site_id: site.id, 
        page: 1,
        size: 20,
        sort: 'timestamp__desc',
        capture_ids: [event_capture.id],
        group_ids: [],
        from_date: '2023-01-21',
        to_date: '2023-01-27'
      }
      graphql_request(event_feed_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['eventFeed']
      expect(response['items']).to eq([])
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['eventFeed']
      expect(response['pagination']).to eq(
        'pageSize' => 20,
        'total' => 0,
        'sort' => 'timestamp__desc'
      )
    end
  end

  context 'when there are events in a single capture' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:rule) { { matcher: 'equals', condition: 'or', value: '/' } }
    let(:event_capture) { create(:event_capture, site:, event_type: EventCapture::PAGE_VISIT, rules: [rule]) }

    let(:recording_1) { create(:recording, site:) }
    let(:recording_2) { create(:recording, site:) }

    before do
      ClickHouse::PageEvent.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_1.id,
          url: '/',
          exited_at: 1674345600000
        }
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_2.id,
          url: '/',
          exited_at: 1674345600000
        }
      end
    end

    subject do
      variables = {
        site_id: site.id, 
        page: 1,
        size: 20,
        sort: 'timestamp__desc',
        capture_ids: [event_capture.id],
        group_ids: [],
        from_date: '2023-01-21',
        to_date: '2023-01-27'
      }
      graphql_request(event_feed_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['eventFeed']
      expect(response['items']).to match_array([
        {
          'id' => anything,
          'data' => '{}',
          'eventName' => event_capture.name,
          'recording' => {
            'id' => recording_1.id.to_s,
            'bookmarked' => false,
            'sessionId' => recording_1.session_id,
          },
          'source' => 'web',
          'timestamp' => '2023-01-22T00:00:00Z',
          'visitor' => {
            'id' => recording_1.visitor.id.to_s,
            'starred' => false,
            'visitorId' => recording_1.visitor.visitor_id
          }
        },
        {
          'id' => anything,
          'data' => '{}',
          'eventName' => event_capture.name,
          'recording' => {
            'id' => recording_2.id.to_s,
            'bookmarked' => false,
            'sessionId' => recording_2.session_id,
          },
          'source' => 'web',
          'timestamp' => '2023-01-22T00:00:00Z',
          'visitor' => {
            'id' => recording_2.visitor.id.to_s,
            'starred' => false,
            'visitorId' => recording_2.visitor.visitor_id
          }
        }
      ])
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['eventFeed']
      expect(response['pagination']).to eq(
        'pageSize' => 20,
        'total' => 2,
        'sort' => 'timestamp__desc'
      )
    end
  end

  context 'when there are some custom events from the API' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:visitor) { create(:visitor, site_id: site.id) }

    let(:rule) { { matcher: 'equals', condition: 'or', value: 'my-event' } }
    let(:event_capture) { create(:event_capture, site:, event_type: EventCapture::CUSTOM, rules: [rule]) }

    before do
      ClickHouse::CustomEvent.insert do |buffer|
        2.times do |i|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            recording_id: nil,
            name: 'my-event',
            data: '{"foo":"bar"}',
            visitor_id: visitor.id,
            source: EventCapture::API,
            timestamp: 1674345600000 + i
          }
        end
      end
    end

    subject do
      variables = {
        site_id: site.id, 
        page: 1,
        size: 20,
        sort: 'timestamp__desc',
        capture_ids: [event_capture.id],
        group_ids: [],
        from_date: '2023-01-21',
        to_date: '2023-01-27'
      }
      graphql_request(event_feed_query, variables, user)
    end

    it 'returns the custom events without recordings' do
      response = subject['data']['site']['eventFeed']
      expect(response['items']).to match_array([
        {
          'id' => anything,
          'data' => '{"foo":"bar"}',
          'eventName' => event_capture.name,
          'recording' => nil,
          'source' => 'api',
          'timestamp' => '2023-01-22T00:00:00Z',
          'visitor' => {
            'id' => visitor.id.to_s,
            'starred' => false,
            'visitorId' => visitor.visitor_id
          }
        },
        {
          'id' => anything,
          'data' => '{"foo":"bar"}',
          'eventName' => event_capture.name,
          'recording' => nil,
          'source' => 'api',
          'timestamp' => '2023-01-22T00:00:00Z',
          'visitor' => {
            'id' => visitor.id.to_s,
            'starred' => false,
            'visitorId' => visitor.visitor_id
          }
        }
      ])
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['eventFeed']
      expect(response['pagination']).to eq(
        'pageSize' => 20,
        'total' => 2,
        'sort' => 'timestamp__desc'
      )
    end
  end
end
