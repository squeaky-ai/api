# frozen_string_literal: true

require 'rails_helper'

event_history_stats_query = <<-GRAPHQL
  query($site_id: ID!, $group_ids: [ID!]!, $capture_ids: [ID!]!) {
    site(siteId: $site_id) {
      eventHistoryStats(groupIds: $group_ids, captureIds: $capture_ids) {
        name
        type
        count
        averageEventsPerVisitor 
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Events::HistoryStats, type: :request do
  context 'when there is no data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { 
        site_id: site.id,
        group_ids: [],
        capture_ids: []
      }
      graphql_request(event_history_stats_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['eventHistoryStats']
      expect(response).to eq([])
    end
  end

  context 'when there is some data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    # A recording/visitor needs to exist
    before { create(:recording, site:) }

    let(:group_1) { create(:event_group, site:, name: 'Group 1') }
    let(:group_2) { create(:event_group, site:, name: 'Group 2') }
    let(:capture_1) { create(:event_capture, site:, name: 'Capture 1', count: 1) }
    let(:capture_2) { create(:event_capture, site:, name: 'Capture 2', count: 3) }

    subject do
      variables = { 
        site_id: site.id,
        group_ids: [group_1.id, group_2.id],
        capture_ids: [capture_1.id, capture_2.id]
      }
      graphql_request(event_history_stats_query, variables, user)
    end

    it 'returns the results' do
      response = subject['data']['site']['eventHistoryStats']
      expect(response).to match_array (
        [
          {
            'averageEventsPerVisitor' => 0.0,
            'count' => 0,
            'name' => 'Group 1',
            'type' => 'group'
          },
          
          {
            'averageEventsPerVisitor' => 0.0,
            'count' => 0,
            'name' => 'Group 2',
            'type' => 'group'
          },
          {
            'averageEventsPerVisitor' => 1.0,
            'count' => 1,
            'name' => 'Capture 1',
            'type' => 'capture'
          },
          {
            'averageEventsPerVisitor' => 3.0,
            'count' => 3,
            'name' => 'Capture 2',
            'type' => 'capture'
          }
        ]
      )
    end
  end
end
