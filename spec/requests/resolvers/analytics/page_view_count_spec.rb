# frozen_string_literal: true

require 'rails_helper'

analytics_page_views_count_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        pageViewCount {
          total
          trend
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::PageViewCount, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_page_views_count_query, variables, user)
    end

    it 'returns 0' do
      response = subject['data']['site']['analytics']
      expect(response['pageViewCount']).to eq(
        'total' => 0,
        'trend' => 0
      )
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          exited_at: Time.new(2021, 8, 7).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          exited_at: Time.new(2021, 8, 6).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test',
          exited_at: Time.new(2021, 8, 6).to_i * 1000
        }
      ]
    end

    before do
      ClickHouse::PageEvent.insert do |buffer|
        pages.each { |page| buffer << page }
      end
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_page_views_count_query, variables, user)
    end

    it 'returns the page views count' do
      response = subject['data']['site']['analytics']
      expect(response['pageViewCount']).to eq(
        'total' => 3,
        'trend' => 3
      )
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          exited_at: Time.new(2021, 8, 7).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          exited_at: Time.new(2021, 8, 6).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test',
          exited_at: Time.new(2021, 8, 6).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/contact',
          exited_at: Time.new(2021, 7, 6).to_i * 1000
        }
      ]
    end

    before do
      ClickHouse::PageEvent.insert do |buffer|
        pages.each { |page| buffer << page }
      end
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_page_views_count_query, variables, user)
    end

    it 'returns the page views counts' do
      response = subject['data']['site']['analytics']
      expect(response['pageViewCount']).to eq(
        'total' => 3,
        'trend' => 3
      )
    end
  end
end
