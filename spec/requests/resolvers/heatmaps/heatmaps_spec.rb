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
end
