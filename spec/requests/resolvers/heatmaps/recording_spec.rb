# typed: false
# frozen_string_literal: true

require 'rails_helper'

heatmaps_recording_query = <<-GRAPHQL
  query($site_id: ID!, $type: HeatmapsType!, $device: HeatmapsDevice!, $page: String!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      heatmaps(device: $device, type: $type, page: $page, fromDate: $from_date, toDate: $to_date) {
        recording {
          id
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Heatmaps::Recording, type: :request do
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
      graphql_request(heatmaps_recording_query, variables, user)
    end

    it 'returns empty data' do
      response = subject['data']['site']['heatmaps']['recording']

      expect(response).to eq nil
    end
  end

  context 'when there is data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recording) { create(:recording, site:) }

    before do
      ClickHouse::Recording.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          viewport_x: 1440,
          connected_at: 1651153548000,
          disconnected_at: 1651153550000,
          recording_id: recording.id
        }
      end

      ClickHouse::PageEvent.insert do |buffer|
        buffer <<  {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          url: '/',
          entered_at: 1653260400000,
          exited_at: 1653260404000
        }
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
      graphql_request(heatmaps_recording_query, variables, user)
    end

    it 'returns the data' do
      response = subject['data']['site']['heatmaps']['recording']

      expect(response).to eq(
        'id' => recording.id.to_s
      )
    end
  end
end
