# frozen_string_literal: true

require 'rails_helper'

analytics_dimensions_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        dimensions {
          min
          max
          avg
        }
      }
    }
  }
GRAPHQL

RSpec.describe Types::AnalyticsDimensionsExtension, type: :request do
  context 'when there are no recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_dimensions_query, variables, user)
    end

    it 'returns 0 for all the stats' do
      response = subject['data']['site']['analytics']
      expect(response['dimensions']).to eq('min' => 0, 'max' => 0, 'avg' => 0)
    end
  end

  context 'when there are some recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ deleted: true, created_at: Date.new(2021, 8, 7), viewport_x: 1920 }, site: site, visitor: create_visitor)
      create_recording({ deleted: true, created_at: Date.new(2021, 8, 6), viewport_x: 2560 }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_dimensions_query, variables, user)
    end

    it 'returns the dimensions stats' do
      response = subject['data']['site']['analytics']
      expect(response['dimensions']).to eq('min' => 1920, 'max' => 2560, 'avg' => 2240)
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ deleted: true, created_at: Date.new(2021, 8, 7), viewport_x: 1920 }, site: site, visitor: create_visitor)
      create_recording({ deleted: true, created_at: Date.new(2021, 8, 6), viewport_x: 2560 }, site: site, visitor: create_visitor)
      create_recording({ deleted: true, created_at: Date.new(2021, 7, 6), viewport_x: 3840 }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_dimensions_query, variables, user)
    end

    it 'returns the dimensions stats' do
      response = subject['data']['site']['analytics']
      expect(response['dimensions']).to eq('min' => 1920, 'max' => 2560, 'avg' => 2240)
    end
  end
end