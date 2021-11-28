# frozen_string_literal: true

require 'rails_helper'

analytics_devices_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        devices {
          type
          count
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::Devices, type: :request do
  context 'when there are no recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_devices_query, variables, user)
    end

    it 'returns 0 for all types' do
      response = subject['data']['site']['analytics']
      expect(response['devices']).to eq(
        [
          {
            'type' => 'mobile',
            'count' => 0
          },
          {
            'type' => 'desktop',
            'count' => 0
          }
        ]
      )
    end
  end

  context 'when there are some recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ disconnected_at: Time.new(2021, 8, 7).to_i * 1000, useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:91.0) Gecko/20100101 Firefox/91.0' }, site: site, visitor: create_visitor)
      create_recording({ disconnected_at: Time.new(2021, 8, 6).to_i * 1000, useragent: '"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15"' }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_devices_query, variables, user)
    end

    it 'returns the devices counts' do
      response = subject['data']['site']['analytics']
      expect(response['devices']).to eq(
        [
          {
            'type' => 'mobile',
            'count' => 0
          },
          {
            'type' => 'desktop',
            'count' => 2
          }
        ]
      )
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ disconnected_at: Time.new(2021, 8, 7).to_i * 1000, useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:91.0) Gecko/20100101 Firefox/91.0' }, site: site, visitor: create_visitor)
      create_recording({ disconnected_at: Time.new(2021, 8, 6).to_i * 1000, useragent: '"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15"' }, site: site, visitor: create_visitor)
      create_recording({ disconnected_at: Time.new(2021, 7, 6).to_i * 1000, useragent: '"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15"' }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_devices_query, variables, user)
    end

    it 'returns the devices counts' do
      response = subject['data']['site']['analytics']
      expect(response['devices']).to eq(
        [
          {
            'type' => 'mobile',
            'count' => 0
          },
          {
            'type' => 'desktop',
            'count' => 2
          }
        ]
      )
    end
  end
end