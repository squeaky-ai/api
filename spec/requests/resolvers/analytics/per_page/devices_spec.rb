# frozen_string_literal: true

require 'rails_helper'

analytics_per_page_devices_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!, $page: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        perPage(page: $page) {
          devices {
            type
            count
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::PerPage::Devices, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        site_id: site.id,
        from_date: '2021-08-01',
        to_date: '2021-08-08',
        page: '/'
      }
      graphql_request(analytics_per_page_devices_query, variables, user)
    end

    it 'returns 0 for all types' do
      response = subject['data']['site']['analytics']['perPage']
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
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, device_type: 'Computer', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, device_type: 'Computer', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, device_type: 'Mobile', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, device_type: 'Mobile', site: site, page_urls: ['/test'])
    end

    subject do
      variables = {
        site_id: site.id,
        from_date: '2021-08-01',
        to_date: '2021-08-08',
        page: '/'
      }
      graphql_request(analytics_per_page_devices_query, variables, user)
    end

    it 'returns the devices counts' do
      response = subject['data']['site']['analytics']['perPage']
      expect(response['devices']).to eq(
        [
          {
            'type' => 'mobile',
            'count' => 1
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
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, device_type: 'Computer', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, device_type: 'Mobile', site: site)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, device_type: 'Computer', site: site)
      create(:recording, disconnected_at: Time.new(2021, 7, 6).to_i * 1000, device_type: 'Computer', site: site)
    end

    subject do
      variables = {
        site_id: site.id,
        from_date: '2021-08-01',
        to_date: '2021-08-08',
        page: '/'
      }
      graphql_request(analytics_per_page_devices_query, variables, user)
    end

    it 'returns the devices counts' do
      response = subject['data']['site']['analytics']['perPage']
      expect(response['devices']).to eq(
        [
          {
            'type' => 'mobile',
            'count' => 1
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
