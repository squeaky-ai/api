# frozen_string_literal: true

require 'rails_helper'

analytics_exists_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        exits {
          url
          percentage
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::Exits, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        site_id: site.id,
        from_date: '2022-08-06',
        to_date: '2022-08-12'
      }
      graphql_request(analytics_exists_query, variables, user)
    end

    it 'returns no results' do
      response = subject['data']['site']['analytics']['exits']
      expect(response).to eq([])
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
          eentered_at: 1660276690000,
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
          eentered_at: 1659603610000,
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
        to_date: '2022-08-12'
      }
      graphql_request(analytics_exists_query, variables, user)
    end

    it 'returns the results' do
      response = subject['data']['site']['analytics']['exits']
      expect(response).to match_array(
        [
          {
            'url' => '/',
            'percentage' => 50.0
          },
          {
            'url' => '/test',
            'percentage' => 0.0
          }
        ]
      )
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
        to_date: '2022-08-12'
      }
      graphql_request(analytics_exists_query, variables, user)
    end

    it 'returns the results' do
      response = subject['data']['site']['analytics']['exits']
      expect(response).to match_array(
        [
          {
            'url' => '/',
            'percentage' => 50.0
          },
          {
            'url' => '/test',
            'percentage' => 0.0
          }
        ]
      )
    end
  end
end
