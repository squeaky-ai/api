# frozen_string_literal: true

require 'rails_helper'

heatmaps_items_query = <<-GRAPHQL
  query($site_id: ID!, $device: HeatmapsDevice!, $type: HeatmapsType!, $page: String!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      heatmaps(device: $device, type: $type, page: $page, fromDate: $from_date, toDate: $to_date) {
        items
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Heatmaps::Items, type: :request do
  context 'when the type is click_count' do
    context 'when there is no data for this page' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      subject do
        variables = {
          site_id: site.id,
          device: 'Desktop',
          page: '/',
          type: 'ClickCount',
          from_date: '2021-08-01',
          to_date: '2021-08-08'
        }
        graphql_request(heatmaps_items_query, variables, user)
      end

      it 'returns empty data' do
        response = subject['data']['site']['heatmaps']['items']

        expect(response).to eq([].to_json)
      end
    end

    context 'when there is data for the clicks' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      before do
        ClickHouse::ClickEvent.insert do |buffer|
          5.times do |_i|
            buffer << {
              uuid: SecureRandom.uuid,
              site_id: site.id,
              url: '/',
              selector: 'html > body',
              coordinates_x: 10,
              coordinates_y: 10,
              viewport_x: 1920,
              viewport_y: 1080,
              device_x: 1920,
              device_y: 1080,
              relative_to_element_x: 0,
              relative_to_element_y: 0,
              timestamp: 1651153548001
            }
          end

          3.times do |_i|
            buffer << {
              uuid: SecureRandom.uuid,
              site_id: site.id,
              url: '/',
              selector: 'p#foo',
              coordinates_x: 10,
              coordinates_y: 10,
              viewport_x: 1920,
              viewport_y: 1080,
              device_x: 1920,
              device_y: 1080,
              relative_to_element_x: 0,
              relative_to_element_y: 0,
              timestamp: 1651153548001
            }
          end
        end
      end

      subject do
        variables = {
          site_id: site.id,
          device: 'Desktop',
          page: '/',
          type: 'ClickCount',
          from_date: '2022-04-23',
          to_date: '2022-04-30'
        }
        graphql_request(heatmaps_items_query, variables, user)
      end

      it 'returns the data' do
        response = subject['data']['site']['heatmaps']['items']

        expect(response).to eq(
          [
            {
              'selector' => 'html > body',
              'count' => 5
            },
            {
              'selector' => 'p#foo',
              'count' => 3
            }
          ].to_json
        )
      end
    end
  end

  context 'when the type is click_position' do
    context 'when there is no data for this page' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      subject do
        variables = {
          site_id: site.id,
          device: 'Desktop',
          page: '/',
          type: 'ClickPosition',
          from_date: '2021-08-01',
          to_date: '2021-08-08'
        }
        graphql_request(heatmaps_items_query, variables, user)
      end

      it 'returns empty data' do
        response = subject['data']['site']['heatmaps']['items']

        expect(response).to eq([].to_json)
      end
    end

    context 'when there is data for the clicks' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      before do
        ClickHouse::ClickEvent.insert do |buffer|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            url: '/',
            selector: 'html > body',
            coordinates_x: 10,
            coordinates_y: 10,
            viewport_x: 1920,
            viewport_y: 1080,
            device_x: 1920,
            device_y: 1080,
            relative_to_element_x: 10,
            relative_to_element_y: 10,
            timestamp: 1651153548001
          }
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            url: '/',
            selector: 'p#foo',
            coordinates_x: 10,
            coordinates_y: 10,
            viewport_x: 1920,
            viewport_y: 1080,
            device_x: 1920,
            device_y: 1080,
            relative_to_element_x: 10,
            relative_to_element_y: 10,
            timestamp: 1651153548001
          }
        end
      end

      subject do
        variables = {
          site_id: site.id,
          device: 'Desktop',
          page: '/',
          type: 'ClickPosition',
          from_date: '2022-04-23',
          to_date: '2022-04-30'
        }
        graphql_request(heatmaps_items_query, variables, user)
      end

      it 'returns the data' do
        response = subject['data']['site']['heatmaps']['items']

        expect(response).to eq(
          [
            {
              'selector' => 'html > body',
              'relative_to_element_x' => 10,
              'relative_to_element_y' => 10
            },
            {
              'selector' => 'p#foo',
              'relative_to_element_x' => 10,
              'relative_to_element_y' => 10
            }
          ].to_json
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

        expect(response).to eq([].to_json)
      end
    end

    context 'when there is data for the clicks' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      before do
        ClickHouse::ScrollEvent.insert do |buffer|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            url: '/',
            x: 10,
            y: 10,
            viewport_x: 1920,
            viewport_y: 1080,
            device_x: 1920,
            device_y: 1080,
            timestamp: 1651153548001
          }
        end
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

        expect(response).to eq(
          [
            {
              'y' => 10
            }
          ].to_json
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

        expect(response).to eq([].to_json)
      end
    end

    context 'when there is data for the cursors' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      before do
        ClickHouse::CursorEvent.insert do |buffer|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: site.id,
            url: '/',
            coordinates: [
              {
                absolute_x: 1353,
                absolute_y: 660
              },
              {
                absolute_x: 1353,
                absolute_y: 661
              },
              {
                absolute_x: 1353,
                absolute_y: 670
              },
              {
                absolute_x: 1353,
                absolute_y: 675
              },
              {
                absolute_x: 1353,
                absolute_y: 676
              }
            ].to_json,
            viewport_x: 1920,
            viewport_y: 1080,
            device_x: 1920,
            device_y: 1080,
            timestamp: 1651153548001
          }
        end
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

        expect(response).to eq(
          [
            {
              'x' => 1360,
              'y' => 672,
              'count' => 3
            },
            {
              'x' => 1360,
              'y' => 688,
              'count' => 2
            }
          ].to_json
        )
      end
    end
  end
end
