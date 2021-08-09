# frozen_string_literal: true

require 'rails_helper'

analytics_visitors_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        visitors
      }
    }
  }
GRAPHQL

RSpec.describe Types::AnalyticsVisitorsExtension, type: :request do
  context 'when there are no recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_visitors_query, variables, user)
    end

    it 'returns 0' do
      response = subject['data']['site']['analytics']
      expect(response['visitors']).to eq 0
    end
  end

  context 'when there are some recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ deleted: true, created_at: Date.new(2021, 8, 7), viewer_id: 'aaaaaaa' }, site: site)
      create_recording({ deleted: true, created_at: Date.new(2021, 8, 5), viewer_id: 'aaaaaaa' }, site: site)
      create_recording({ deleted: true, created_at: Date.new(2021, 8, 6), viewer_id: 'bbbbbbb' }, site: site)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_visitors_query, variables, user)
    end

    it 'returns the number of unique viewers' do
      response = subject['data']['site']['analytics']
      expect(response['visitors']).to eq 2
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ deleted: true, created_at: Date.new(2021, 8, 7), viewer_id: 'aaaaaaa' }, site: site)
      create_recording({ deleted: true, created_at: Date.new(2021, 8, 5), viewer_id: 'aaaaaaa' }, site: site)
      create_recording({ deleted: true, created_at: Date.new(2021, 8, 6), viewer_id: 'bbbbbbb' }, site: site)
      create_recording({ deleted: true, created_at: Date.new(2021, 7, 6), viewer_id: 'bbbbbbb' }, site: site)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_visitors_query, variables, user)
    end

    it 'returns the number of unique viewers' do
      response = subject['data']['site']['analytics']
      expect(response['visitors']).to eq 2
    end
  end
end
