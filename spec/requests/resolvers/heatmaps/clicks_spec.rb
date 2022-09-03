# frozen_string_literal: true

require 'rails_helper'

heatmaps_clicks_query = <<-GRAPHQL
  query($site_id: ID!, $device: HeatmapsDevice!, $page: String!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      heatmaps(device: $device, page: $page, fromDate: $from_date, toDate: $to_date) {
        clicks {
          selector
          count
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Heatmaps::Clicks, type: :request do
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
      graphql_request(heatmaps_clicks_query, variables, user)
    end

    it 'returns empty data' do
      response = subject['data']['site']['heatmaps']['clicks']

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
        from_date: '2022-04-23', 
        to_date: '2022-04-30' 
      }
      graphql_request(heatmaps_clicks_query, variables, user)
    end

    it 'returns the data' do
      response = subject['data']['site']['heatmaps']['clicks']

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
