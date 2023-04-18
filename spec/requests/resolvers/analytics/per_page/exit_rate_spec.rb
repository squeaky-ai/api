# frozen_string_literal: true

require 'rails_helper'

analytics_per_page_exit_rate_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!, $page: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        perPage(page: $page) {
          exitRate {
            average
            trend
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::PerPage::ExitRate, type: :request do
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
      graphql_request(analytics_per_page_exit_rate_query, variables, user)
    end

    it 'returns zero' do
      response = subject['data']['site']['analytics']['perPage']['exitRate']
      expect(response).to eq('average' => 0, 'trend' => 0)
    end
  end

  context 'when there are some pages' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1660276690000, 
          exited_at: 1660276750000, 
          exited_on: true
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1659945610000, 
          exited_at: 1659949210000, 
          exited_on: false
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test', 
          entered_at: 1659945610000, 
          exited_at: 1659945610000, 
          exited_on: false
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1659603610000, 
          exited_at: 1659607210000, 
          exited_on: true
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1659603610000, 
          exited_at: 1659607210000, 
          exited_on: false
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1659603610000, 
          exited_at: 1659607210000, 
          exited_on: false
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
      graphql_request(analytics_per_page_exit_rate_query, variables, user)
    end

    it 'returns the results' do
      response = subject['data']['site']['analytics']['perPage']['exitRate']
      expect(response).to eq('average' => 50.00, 'trend' => 16.67)
    end
  end

  context 'when there are some pages that are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1660276690000, 
          exited_at: 1660276750000, 
          exited_on: true
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1659945610000, 
          exited_at: 1659949210000, 
          exited_on: false
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test', 
          entered_at: 1659945610000, 
          exited_at: 1659945610000, 
          exited_on: false
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1651658410000, 
          exited_at: 1651662010000, 
          exited_on: true
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1659603610000, 
          exited_at: 1659607210000, 
          exited_on: false
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/', 
          entered_at: 1659603610000, 
          exited_at: 1659607210000, 
          exited_on: false
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
      graphql_request(analytics_per_page_exit_rate_query, variables, user)
    end

    it 'returns the results' do
      response = subject['data']['site']['analytics']['perPage']['exitRate']
      expect(response).to eq('average' => 50.00, 'trend' => 50.0)
    end
  end
end
