# frozen_string_literal: true

require 'rails_helper'

site_data_exports_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      dataExports {
        filename
        exportType
        exportedAt {
          iso8601
        }
        startDate {
          iso8601
        }
        endDate {
          iso8601
        }
      }
    }
  }
GRAPHQL

RSpec.describe 'SitesExports', type: :request do
  context 'when there are no exports' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_data_exports_query, variables, user)
    end

    it 'returns an empty list' do
      expect(subject['data']['site']['dataExports']).to eq([])
    end
  end

  context 'when there are some exports' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:data_export, site:, export_type: 0, start_date: '2023-03-16', end_date: '2023-03-16')
      create(:data_export, site:, export_type: 1, start_date: '2023-03-16', end_date: '2023-03-16')
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_data_exports_query, variables, user)
    end

    it 'returns the data exports' do
      expect(subject['data']['site']['dataExports']).to match_array([
        {
          'exportType' => 0,
          'exportedAt' => nil,
          'filename' => 'test.csv',
          'startDate' => {
            'iso8601' => '2023-03-16T00:00:00Z'
          },
          'endDate' => {
            'iso8601' => '2023-03-16T00:00:00Z'
          }
        },
        {
          'exportType' => 1,
          'exportedAt' => nil,
          'filename' => 'test.csv',
          'startDate' => {
            'iso8601' => '2023-03-16T00:00:00Z'
          },
          'endDate' => {
            'iso8601' => '2023-03-16T00:00:00Z'
          }
        }
      ])
    end
  end
end
