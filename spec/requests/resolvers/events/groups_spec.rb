# frozen_string_literal: true

require 'rails_helper'

event_groups_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      eventGroups {
        name
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
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Events::Groups, type: :request do
  context 'when there is no data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(event_groups_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['eventGroups']
      expect(response).to eq([])
    end
  end

  context 'when there is some data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      event_group_1 = create(:event_group, site:, name: 'Group 1')
      event_group_2 = create(:event_group, site:, name: 'Group 2')

      create(:event_capture, site:, event_type: EventCapture::PAGE_VISIT, count: 5, event_groups: [event_group_1])
      create(:event_capture, site:, event_type: EventCapture::ERROR, count: 3, event_groups: [event_group_1])
      create(:event_capture, site:, event_type: EventCapture::TEXT_CLICK, count: 2, event_groups: [event_group_2])
      create(:event_capture, site:, event_type: EventCapture::SELECTOR_CLICK, count: 1)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(event_groups_query, variables, user)
    end

    it 'returns the groups and their items' do
      response = subject['data']['site']['eventGroups']
      expect(response).to eq([
        {
          'name' => 'Group 1',
          'items' => [
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
            }
          ]
        },
        {
          'name' => 'Group 2',
          'items' => [
            {
              'count' => 2,
              'lastCountedAt' => nil,
              'name' => 'My event',
              'rules' => [],
              'type' => 1
            }
          ]
        }
      ])
    end
  end
end
