# frozen_string_literal: true

require 'rails_helper'

analytics_bounce_rate_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        bounceRate {
          average
          trend
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::BounceRate, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        site_id: site.id,
        from_date: '2022-08-06',
        to_date: '2022-08-12'
      }
      graphql_request(analytics_bounce_rate_query, variables, user)
    end

    it 'returns zero' do
      response = subject['data']['site']['analytics']['bounceRate']
      expect(response).to eq('average' => 0, 'trend' => 0)
    end
  end

  context 'when there are some pages' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:events) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          entered_at: 1660276690000, 
          exited_at: 1660276750000, 
          bounced_on: true
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          entered_at: 1659945610000, 
          exited_at: 1659949210000, 
          bounced_on: false
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          entered_at: 1659945610000, 
          exited_at: 1659945610000, 
          bounced_on: false
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          entered_at: 1659603610000, 
          exited_at: 1659607210000, 
          bounced_on: true
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          entered_at: 1659603610000, 
          exited_at: 1659607210000, 
          bounced_on: false
        }
      ]
    end

    before do
      ClickHouse::PageEvent.insert do |buffer|
        events.each { |event| buffer << event }
      end
    end

    subject do
      variables = {
        site_id: site.id,
        from_date: '2022-08-06',
        to_date: '2022-08-12'
      }
      graphql_request(analytics_bounce_rate_query, variables, user)
    end

    it 'returns the results' do
      response = subject['data']['site']['analytics']['bounceRate']
      expect(response).to eq('average' => 33.33, 'trend' => -16.67)
    end
  end

  context 'when there are some pages that are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:events) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          entered_at: 1660276690000, 
          exited_at: 1660276750000, 
          bounced_on: true
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          entered_at: 1659945610000, 
          exited_at: 1659949210000, 
          bounced_on: false
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          entered_at: 1659945610000, 
          exited_at: 1659945610000, 
          bounced_on: false
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          entered_at: 1651658410000, 
          exited_at: 1651662010000, 
          bounced_on: true
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          entered_at: 1659603610000, 
          exited_at: 1659607210000, 
          bounced_on: false
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          entered_at: 1659603610000, 
          exited_at: 1659607210000, 
          bounced_on: false
        }
      ]
    end

    before do
      ClickHouse::PageEvent.insert do |buffer|
        events.each { |event| buffer << event }
      end
    end

    subject do
      variables = {
        site_id: site.id,
        from_date: '2022-08-06',
        to_date: '2022-08-12'
      }
      graphql_request(analytics_bounce_rate_query, variables, user)
    end

    it 'returns the results' do
      response = subject['data']['site']['analytics']['bounceRate']
      expect(response).to eq('average' => 33.33, 'trend' => 33.33)
    end
  end
end
