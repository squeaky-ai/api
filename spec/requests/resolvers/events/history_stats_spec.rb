# typed: false
# frozen_string_literal: true

require 'rails_helper'

event_history_stats_query = <<-GRAPHQL
  query($site_id: ID!, $group_ids: [ID!]!, $capture_ids: [ID!]!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      eventStats(groupIds: $group_ids, captureIds: $capture_ids, fromDate: $from_date, toDate: $to_date) {
        name
        type
        count
        uniqueTriggers
        averageEventsPerVisitor 
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Events::Stats, type: :request do
  context 'when there is no data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { 
        site_id: site.id,
        group_ids: [],
        capture_ids: [],
        from_date: '2022-06-02',
        to_date: '2022-06-16'
      }
      graphql_request(event_history_stats_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['eventStats']
      expect(response).to eq([])
    end
  end

  context 'when there is some data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site:) }

    let(:rule_1) do
      {
        value: '/',
        matcher: 'equals',
        condition: 'or'
      }
    end

    let(:rule_2) do
      {
        value: '/test',
        matcher: 'contains',
        condition: 'or'
      }
    end

    let(:group_1) { create(:event_group, site:, name: 'Group 1') }
    let(:group_2) { create(:event_group, site:, name: 'Group 2') }
    let(:capture_1) { create(:event_capture, site:, event_type: EventCapture::PAGE_VISIT, name: 'Capture 1', rules: [rule_1]) }
    let(:capture_2) { create(:event_capture, site:, event_type: EventCapture::PAGE_VISIT, name: 'Capture 2', rules: [rule_2]) }

    before do
      group_1.update(event_captures: [capture_1, capture_2])

      ClickHouse::Recording.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id
        }
      end

      ClickHouse::PageEvent.insert do |buffer|
        5.times do |i|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            recording_id: recording.id,
            url: '/',
            exited_at: (Time.new(2022, 6, 2, 12, 0, 0) + i.days).utc.to_i * 1000,
            visitor_id: recording.visitor_id
          }
        end

        3.times do |i|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            recording_id: recording.id,
            url: '/test',
            exited_at: (Time.new(2022, 6, 2, 12, 0, 0) + i.days).utc.to_i * 1000,
            visitor_id: recording.visitor_id
          }
        end

        3.times do |i|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            recording_id: recording.id,
            url: '/something_else',
            exited_at: (Time.new(2022, 6, 2, 12, 0, 0) + i.days).utc.to_i * 1000,
            visitor_id: recording.visitor_id
          }
        end
      end
    end

    subject do
      variables = { 
        site_id: site.id,
        group_ids: [group_1.id, group_2.id],
        capture_ids: [capture_1.id, capture_2.id],
        from_date: '2022-06-02',
        to_date: '2022-06-16'
      }
      graphql_request(event_history_stats_query, variables, user)
    end

    it 'returns the results' do
      response = subject['data']['site']['eventStats']
      expect(response).to match_array(
        [
          {
            'averageEventsPerVisitor' => 4.0,
            'uniqueTriggers' => 2,
            'count' => 8,
            'name' => 'Group 1',
            'type' => 'group'
          },
          {
            'averageEventsPerVisitor' => 0.0,
            'uniqueTriggers' => 0,
            'count' => 0,
            'name' => 'Group 2',
            'type' => 'group'
          },
          {
            'averageEventsPerVisitor' => 5.0,
            'uniqueTriggers' => 1,
            'count' => 5,
            'name' => 'Capture 1',
            'type' => 'capture'
          },
          {
            'averageEventsPerVisitor' => 3.0,
            'uniqueTriggers' => 1,
            'count' => 3,
            'name' => 'Capture 2',
            'type' => 'capture'
          }
        ]
      )
    end
  end
end
