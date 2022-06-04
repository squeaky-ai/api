# frozen_string_literal: true

require 'rails_helper'

event_capture_query = <<-GRAPHQL
  query($site_id: ID!, $page: Int, $size: Int, $sort: EventsCaptureSort) {
    site(siteId: $site_id) {
      eventCapture(page: $page, size: $size, sort: $sort) {
        items {
          name
          type
          rules {
            condition
            value
            type
          }
          count
          lastCountedAt
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

RSpec.describe Resolvers::Events::Capture, type: :request do
  context 'when there is no data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { 
        site_id: site.id, 
        page: 1,
        size: 20,
        sort: 'count_desc'
      }
      graphql_request(event_capture_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['eventCapture']
      expect(response['items']).to eq([])
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['eventCapture']
      expect(response['pagination']).to eq(
        'pageSize' => 20,
        'total' => 0,
        'sort' => 'count_desc'
      )
    end
  end
  
  context 'when there is some data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:event_capture, site:, event_type: EventCapture::PAGE_VISIT, count: 5)
      create(:event_capture, site:, event_type: EventCapture::ERROR, count: 3)
      create(:event_capture, site:, event_type: EventCapture::TEXT_CLICK, count: 2)
      create(:event_capture, site:, event_type: EventCapture::SELECTOR_CLICK, count: 1)
    end

    subject do
      variables = { 
        site_id: site.id, 
        page: 1,
        size: 20,
        sort: 'count_desc'
      }
      graphql_request(event_capture_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['eventCapture']
      expect(response['items']).to match_array([
        {
          'count' => 5,
          'lastCountedAt' => nil,
          'name' => 'My event',
          'rules' => [],
          'type' => 0
        },
        {
          'count' => 3,
          'lastCountedAt' => nil,
          'name' => 'My event',
          'rules' => [],
          'type' => 3
        },
        {
          'count' => 2,
          'lastCountedAt' => nil,
          'name' => 'My event',
          'rules' => [],
          'type' => 1
        },
        {
          'count' => 1,
          'lastCountedAt' => nil,
          'name' => 'My event',
          'rules' => [],
          'type' => 2
        }
      ])
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['eventCapture']
      expect(response['pagination']).to eq(
        'pageSize' => 20,
        'total' => 4,
        'sort' => 'count_desc'
      )
    end
  end
end
