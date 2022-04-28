# frozen_string_literal: true

require 'rails_helper'

heatmaps_query = <<-GRAPHQL
  query($site_id: ID!, $device: HeatmapsDevice!, $type: HeatmapsType!, $page: String!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      heatmaps(device: $device, type: $type, page: $page, fromDate: $from_date, toDate: $to_date) {
        desktopCount
        tabletCount
        mobileCount
        recordingId
        items {
          x
          y
          selector
          count
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Heatmaps::Heatmaps, type: :request do
  context 'when there is no data for this page' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { 
        site_id: site.id,
        device: 'Desktop',
        type: 'Click',
        page: '/',
        from_date: '2021-08-01', 
        to_date: '2021-08-08' 
      }
      graphql_request(heatmaps_query, variables, user)
    end

    it 'returns empty data' do
      response = subject['data']['site']['heatmaps']

      expect(response).to eq(
        'desktopCount' => 0,
        'tabletCount' => 0,
        'mobileCount' => 0,
        'recordingId' => nil,
        'items' => []
      )
    end
  end

  context 'when there is data for the clicks' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, viewport_x: 960, connected_at: 1651153548000, disconnected_at: 1651153550000, site:)
      create(:recording, viewport_x: 1440, connected_at: 1651153548000, disconnected_at: 1651153550000, site:)
      create(:recording, viewport_x: 360, connected_at: 1651153548000, disconnected_at: 1651153550000, site:)
      create(:recording, viewport_x: 360, connected_at: 1651153548000, disconnected_at: 1651153550000, site:)
      create(:recording, viewport_x: 360, connected_at: 1651153548000, disconnected_at: 1651153550000, site:)
      create(:recording, viewport_x: 4096, connected_at: 1651153548000, disconnected_at: 1651153550000, site:)
      create(:recording, viewport_x: 1024, connected_at: 1651153548000, disconnected_at: 1651153550000, site:)

      5.times do |i|
        create(:click, site:, viewport_x: 1440, clicked_at: 1651153548001)
      end

      3.times do |i|
        create(:click, selector: 'p#foo', site:, viewport_x: 1440, clicked_at: 1651153548001)
      end
    end

    subject do
      variables = { 
        site_id: site.id,
        device: 'Desktop',
        type: 'Click',
        page: '/',
        from_date: '2022-04-23', 
        to_date: '2022-04-30' 
      }
      graphql_request(heatmaps_query, variables, user)
    end

    it 'returns the data' do
      response = subject['data']['site']['heatmaps']

      expect(response).to match(a_hash_including(
        'desktopCount' => 2,
        'tabletCount' => 2,
        'mobileCount' => 3,
        'recordingId' => anything,
        'items' => [
          {
            'count' => 5,
            'selector' => 'html > body',
            'x' => nil,
            'y' => nil
          },
          {
            'count' => 3,
            'selector' => 'p#foo',
            'x' => nil,
            'y' => nil
          }
        ]
      ))
    end
  end
end
