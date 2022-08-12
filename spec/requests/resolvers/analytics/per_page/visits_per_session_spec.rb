# frozen_string_literal: true

require 'rails_helper'

analytics_per_page_per_session_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!, $page: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        perPage(page: $page) {
          averageVisitsPerSession {
            average
            trend
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::PerPage::VisitsPerSession, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        site_id: site.id,
        from_date: '2022-08-06',
        to_date: '2022-08-12',
        page: '/'
      }
      graphql_request(analytics_per_page_per_session_query, variables, user)
    end

    it 'returns zero' do
      response = subject['data']['site']['analytics']['perPage']['averageVisitsPerSession']
      expect(response).to eq('average' => 0, 'trend' => 0)
    end
  end

  context 'when there are some pages' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      recording_1 = create(:recording, site:)
      recording_2 = create(:recording, site:)
      recording_3 = create(:recording, site:)
      recording_4 = create(:recording, site:)

      create(:page, url: '/', entered_at: 1660276690000, exited_at: 1660276750000, recording: recording_1, site_id: site.id)
      create(:page, url: '/', entered_at: 1660276690001, exited_at: 1660276750001, recording: recording_1, site_id: site.id)
      create(:page, url: '/', entered_at: 1659945610000, exited_at: 1659949210000, recording: recording_2, site_id: site.id)
      create(:page, url: '/test', entered_at: 1659945610000, exited_at: 1659945610000, recording: recording_1, site_id: site.id)
      create(:page, url: '/', entered_at: 1659605498000, exited_at: 1659609098000, recording: recording_3, site_id: site.id)
      create(:page, url: '/', entered_at: 1659605498000, exited_at: 1659609098000, recording: recording_3, site_id: site.id)
      create(:page, url: '/', entered_at: 1659605498000, exited_at: 1659609098000, recording: recording_4, site_id: site.id)
      create(:page, url: '/', entered_at: 1659605498000, exited_at: 1659609098000, recording: recording_4, site_id: site.id)
    end

    subject do
      variables = {
        site_id: site.id,
        from_date: '2022-08-06',
        to_date: '2022-08-12',
        page: '/'
      }
      graphql_request(analytics_per_page_per_session_query, variables, user)
    end

    it 'returns the results' do
      response = subject['data']['site']['analytics']['perPage']['averageVisitsPerSession']
      expect(response).to eq('average' => 1.5, 'trend' => -0.5)
    end
  end

  context 'when there are some pages that are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      recording_1 = create(:recording, site:)
      recording_2 = create(:recording, site:)
      recording_3 = create(:recording, site:)
      recording_4 = create(:recording, site:)
      recording_5 = create(:recording, site:)

      create(:page, url: '/', entered_at: 1660276690000, exited_at: 1660276750000, recording: recording_1, site_id: site.id)
      create(:page, url: '/', entered_at: 1660276690001, exited_at: 1660276750001, recording: recording_1, site_id: site.id)
      create(:page, url: '/', entered_at: 1659945610000, exited_at: 1659949210000, recording: recording_2, site_id: site.id)
      create(:page, url: '/test', entered_at: 1659945610000, exited_at: 1659945610000, recording: recording_1, site_id: site.id)
      create(:page, url: '/', entered_at: 1659605498000, exited_at: 1659609098000, recording: recording_3, site_id: site.id)
      create(:page, url: '/', entered_at: 1659605498000, exited_at: 1659609098000, recording: recording_3, site_id: site.id)
      create(:page, url: '/', entered_at: 1659605498000, exited_at: 1659609098000, recording: recording_4, site_id: site.id)
      create(:page, url: '/', entered_at: 1659605498000, exited_at: 1659609098000, recording: recording_4, site_id: site.id)
      create(:page, url: '/', entered_at: 1656671498000, exited_at: 1656675098000, recording: recording_5, site_id: site.id)
      create(:page, url: '/', entered_at: 1656671498000, exited_at: 1656675098000, recording: recording_5, site_id: site.id)
    end

    subject do
      variables = {
        site_id: site.id,
        from_date: '2022-08-06',
        to_date: '2022-08-12',
        page: '/'
      }
      graphql_request(analytics_per_page_per_session_query, variables, user)
    end

    it 'returns the results' do
      response = subject['data']['site']['analytics']['perPage']['averageVisitsPerSession']
      expect(response).to eq('average' => 1.5, 'trend' => -0.5)
    end
  end
end
