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
    let(:recording_1) { create(:recording, site:) }
    let(:recording_2) { create(:recording, site:) }
    let(:recording_3) { create(:recording, site:) }
    let(:recording_4) { create(:recording, site:) }

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1660276690000,
          exited_at: 1660276750000, 
          recording_id: recording_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1660276690001,
          exited_at: 1660276750001, 
          recording_id: recording_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1659945610000,
          exited_at: 1659949210000, 
          recording_id: recording_2.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test', 
          entered_at: 1659945610000,
          exited_at: 1659945610000, 
          recording_id: recording_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1659605498000,
          exited_at: 1659609098000, 
          recording_id: recording_3.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1659605498000,
          exited_at: 1659609098000, 
          recording_id: recording_3.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1659605498000,
          exited_at: 1659609098000, 
          recording_id: recording_4.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1659605498000,
          exited_at: 1659609098000, 
          recording_id: recording_4.id
        }
      ]
    end

    before do
      ClickHouse::PageEvent.insert do |buffer|
        pages.each { |page| buffer << page }
      end
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
    let(:recording_1) { create(:recording, site:) }
    let(:recording_2) { create(:recording, site:) }
    let(:recording_3) { create(:recording, site:) }
    let(:recording_4) { create(:recording, site:) }
    let(:recording_5) { create(:recording, site:) }

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1660276690000, 
          exited_at: 1660276750000, 
          recording_id: recording_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1660276690001, 
          exited_at: 1660276750001, 
          recording_id: recording_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1659945610000, 
          exited_at: 1659949210000, 
          recording_id: recording_2.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test', 
          entered_at: 1659945610000, 
          exited_at: 1659945610000, 
          recording_id: recording_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1659605498000, 
          exited_at: 1659609098000, 
          recording_id: recording_3.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1659605498000, 
          exited_at: 1659609098000, 
          recording_id: recording_3.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1659605498000, 
          exited_at: 1659609098000, 
          recording_id: recording_4.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1659605498000, 
          exited_at: 1659609098000, 
          recording_id: recording_4.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1656671498000, 
          exited_at: 1656675098000, 
          recording_id: recording_5.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1656671498000, 
          exited_at: 1656675098000, 
          recording_id: recording_5.id
        }
      ]
    end

    before do
      ClickHouse::PageEvent.insert do |buffer|
        pages.each { |page| buffer << page }
      end
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
