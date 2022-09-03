# frozen_string_literal: true

require 'rails_helper'

heatmaps_items_query = <<-GRAPHQL
  query($site_id: ID!, $device: HeatmapsDevice!, $type: HeatmapsType!, $page: String!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      heatmaps(device: $device, type: $type, page: $page, fromDate: $from_date, toDate: $to_date) {
        items {
          ... on HeatmapsClick {
            selector
            count
          }
          ... on HeatmapsScroll {
            x
            y
          }
          ... on HeatmapsCursor {
            x
            y
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Heatmaps::Items, type: :request do
  context 'when the type is click' do
    context 'when there is no data for this page' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      subject do
        variables = { 
          site_id: site.id,
          device: 'Desktop',
          page: '/',
          type: 'Click',
          from_date: '2021-08-01', 
          to_date: '2021-08-08' 
        }
        graphql_request(heatmaps_items_query, variables, user)
      end

      it 'returns empty data' do
        response = subject['data']['site']['heatmaps']['items']

        expect(response).to eq([])
      end
    end

    context 'when there is data for the clicks' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      before do
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
          page: '/',
          type: 'Click',
          from_date: '2022-04-23', 
          to_date: '2022-04-30' 
        }
        graphql_request(heatmaps_items_query, variables, user)
      end

      it 'returns the data' do
        response = subject['data']['site']['heatmaps']['items']

        expect(response).to match(
          [
            {
              'count' => 5,
              'selector' => 'html > body'
            },
            {
              'count' => 3,
              'selector' => 'p#foo'
            }
          ]
        )
      end
    end
  end

  context 'when the type is scroll' do
    context 'when there is no data for this page' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
  
      subject do
        variables = { 
          site_id: site.id,
          device: 'Desktop',
          page: '/',
          type: 'Scroll',
          from_date: '2021-08-01', 
          to_date: '2021-08-08' 
        }
        graphql_request(heatmaps_items_query, variables, user)
      end
  
      it 'returns empty data' do
        response = subject['data']['site']['heatmaps']['items']
  
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
          type: 'Scroll',
          from_date: '2022-04-23', 
          to_date: '2022-04-30' 
        }
        graphql_request(heatmaps_items_query, variables, user)
      end
  
      it 'returns the data' do
        response = subject['data']['site']['heatmaps']['items']
  
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
  
  context 'when the type is cursor' do
    context 'when there is no data for this page' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
  
      subject do
        variables = { 
          site_id: site.id,
          device: 'Desktop',
          page: '/',
          type: 'Cursor',
          from_date: '2021-08-01', 
          to_date: '2021-08-08' 
        }
        graphql_request(heatmaps_items_query, variables, user)
      end
  
      it 'returns empty data' do
        response = subject['data']['site']['heatmaps']['items']
  
        expect(response).to eq([])
      end
    end
  
    context 'when there is data for the scrolls' do
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
          data: {
            source: 1,
            positions: [
              {
                x: 1353,
                y: 660
              },
              {
                x: 1353,
                y: 661
              },
              {
                x: 1353,
                y: 670
              },
              {
                x: 1353,
                y: 675
              },
              {
                x: 1353,
                y: 676
              }
            ]
          },
          event_type: 3, 
          timestamp: 1651153548001
        )
      end
  
      subject do
        variables = { 
          site_id: site.id,
          device: 'Desktop',
          page: '/',
          type: 'Cursor',
          from_date: '2022-04-23', 
          to_date: '2022-04-30' 
        }
        graphql_request(heatmaps_items_query, variables, user)
      end
  
      it 'returns the data' do
        response = subject['data']['site']['heatmaps']['items']
  
        expect(response).to match(
          [
            {
              'x' => 1353,
              'y' => 660
            },
            {
              'x' => 1353,
              'y' => 661
            },
            {
              'x' => 1353,
              'y' => 670
            },
            {
              'x' => 1353,
              'y' => 675
            },
            {
              'x' => 1353,
              'y' => 676
            }
          ]
        )
      end
    end
  end
end
