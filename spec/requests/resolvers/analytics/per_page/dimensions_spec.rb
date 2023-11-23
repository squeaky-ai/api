# frozen_string_literal: true

require 'rails_helper'

analytics_per_page_dimensions_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!, $page: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        perPage(page: $page) {
          dimensions {
            deviceX
            count
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::PerPage::Dimensions, type: :request do
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
      graphql_request(analytics_per_page_dimensions_query, variables, user)
    end

    it 'returns 0 for all the stats' do
      response = subject['data']['site']['analytics']['perPage']
      expect(response['dimensions']).to eq([])
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording_1) { create(:recording, site:) }
    let(:recording_2) { create(:recording, site:) }
    let(:recording_3) { create(:recording, site:) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 7).to_i * 1000,
          device_x: 1920,
          recording_id: recording_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 6).to_i * 1000,
          device_x: 2560,
          recording_id: recording_2.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 6).to_i * 1000,
          device_x: 2560,
          recording_id: recording_3.id
        }
      ]
    end

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          recording_id: recording_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          recording_id: recording_2.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test',
          recording_id: recording_3.id
        }
      ]
    end

    before do
      ClickHouse::PageEvent.insert do |buffer|
        pages.each { |page| buffer << page }
      end

      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end
    end

    subject do
      variables = {
        site_id: site.id,
        from_date: '2021-08-01',
        to_date: '2021-08-08',
        page: '/'
      }
      graphql_request(analytics_per_page_dimensions_query, variables, user)
    end

    it 'returns the dimensions stats' do
      response = subject['data']['site']['analytics']['perPage']
      expect(response['dimensions']).to match_array(
        [
          {
            'deviceX' => 1920,
            'count' => 1
          },
          {
            'deviceX' => 2560,
            'count' => 1
          }
        ]
      )
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording_1) { create(:recording, site:) }
    let(:recording_2) { create(:recording, site:) }
    let(:recording_3) { create(:recording, site:) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 7).to_i * 1000,
          device_x: 1920,
          recording_id: recording_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 6).to_i * 1000,
          device_x: 2560,
          recording_id: recording_2.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 7, 6).to_i * 1000,
          device_x: 3840,
          recording_id: recording_3.id
        }
      ]
    end

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          recording_id: recording_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          recording_id: recording_2.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          recording_id: recording_3.id
        }
      ]
    end

    before do
      ClickHouse::PageEvent.insert do |buffer|
        pages.each { |page| buffer << page }
      end

      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end
    end

    subject do
      variables = {
        site_id: site.id,
        from_date: '2021-08-01',
        to_date: '2021-08-08',
        page: '/'
      }
      graphql_request(analytics_per_page_dimensions_query, variables, user)
    end

    it 'returns the dimensions stats' do
      response = subject['data']['site']['analytics']['perPage']
      expect(response['dimensions']).to match_array(
        [
          {
            'deviceX' => 1920,
            'count' => 1
          },
          {
            'deviceX' => 2560,
            'count' => 1
          }
        ]
      )
    end
  end
end
