# frozen_string_literal: true

require 'rails_helper'

heatmaps_scrolls_query = <<-GRAPHQL
  query($site_id: ID!, $device: HeatmapsDevice!, $page: String!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      heatmaps(device: $device, page: $page, fromDate: $from_date, toDate: $to_date) {
        scrolls {
          x
          y
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Heatmaps::Scrolls, type: :request do
  context 'when there is no data for this page' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { 
        site_id: site.id,
        device: 'Desktop',
        page: '/',
        from_date: '2021-08-01', 
        to_date: '2021-08-08' 
      }
      graphql_request(heatmaps_scrolls_query, variables, user)
    end

    it 'returns empty data' do
      response = subject['data']['site']['heatmaps']['scrolls']

      expect(response).to eq([])
    end
  end

  context 'when there is data for the clicks' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let!(:recording) do
      create(:recording, viewport_x: 1440, connected_at: 1651153548000, disconnected_at: 1651153550000, site:)
    end

    before do
      create(
        :page,
        recording:,
        url: '/',
        entered_at: 1651153548000,
        exited_at: 1651153550000
      )

      create(
        :event,
        recording:,
        site_id: site.id,
        data: { x: 10, y: 10, source: 3 },
        event_type: 3, 
        timestamp: 1651153548001
      )
    end

    subject do
      variables = { 
        site_id: site.id,
        device: 'Desktop',
        page: '/',
        from_date: '2022-04-23', 
        to_date: '2022-04-30' 
      }
      graphql_request(heatmaps_scrolls_query, variables, user)
    end

    it 'returns the data' do
      response = subject['data']['site']['heatmaps']['scrolls']

      expect(response).to match(
        [
          {
            'x' => nil,
            'y' => 10
          }
        ]
      )
    end
  end
end
