# frozen_string_literal: true

require 'rails_helper'

heatmaps_counts_query = <<-GRAPHQL
  query($site_id: ID!, $type: HeatmapsType!, $device: HeatmapsDevice!, $page: String!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      heatmaps(device: $device, type: $type, page: $page, fromDate: $from_date, toDate: $to_date) {
        counts {
          desktop
          tablet
          mobile
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Heatmaps::Counts, type: :request do
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
      graphql_request(heatmaps_counts_query, variables, user)
    end

    it 'returns empty data' do
      response = subject['data']['site']['heatmaps']['counts']

      expect(response).to eq(
        'desktop' => 0,
        'tablet' => 0,
        'mobile' => 0
      )
    end
  end

  context 'when there is data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording_1) { create(:recording, site:) }
    let(:recording_2) { create(:recording, site:) }
    let(:recording_3) { create(:recording, site:) }
    let(:recording_4) { create(:recording, site:) }
    let(:recording_5) { create(:recording, site:) }
    let(:recording_6) { create(:recording, site:) }
    let(:recording_7) { create(:recording, site:) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          viewport_x: 960,
          connected_at: 1651153548000,
          disconnected_at: 1651153550000,
          recording_id: recording_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          viewport_x: 1440,
          connected_at: 1651153548000,
          disconnected_at: 1651153550000,
          recording_id: recording_2.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          viewport_x: 360,
          connected_at: 1651153548000,
          disconnected_at: 1651153550000,
          recording_id: recording_3.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          viewport_x: 360,
          connected_at: 1651153548000,
          disconnected_at: 1651153550000,
          recording_id: recording_4.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          viewport_x: 360,
          connected_at: 1651153548000,
          disconnected_at: 1651153550000,
          recording_id: recording_5.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          viewport_x: 4096,
          connected_at: 1651153548000,
          disconnected_at: 1651153550000,
          recording_id: recording_6.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          viewport_x: 1024,
          connected_at: 1651153548000,
          disconnected_at: 1651153550000,
          recording_id: recording_7.id
        }
      ]
    end

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_1.id,
          url: '/'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_2.id,
          url: '/'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_3.id,
          url: '/'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_4.id,
          url: '/'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_5.id,
          url: '/'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_6.id,
          url: '/'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_7.id,
          url: '/'
        }
      ]
    end

    before do
      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end

      ClickHouse::PageEvent.insert do |buffer|
        pages.each { |page| buffer << page }
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
      graphql_request(heatmaps_counts_query, variables, user)
    end

    it 'returns the data' do
      response = subject['data']['site']['heatmaps']['counts']

      expect(response).to eq(
        'desktop' => 2,
        'tablet' => 2,
        'mobile' => 3
      )
    end
  end
end
