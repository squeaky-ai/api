# frozen_string_literal: true

require 'rails_helper'

analytics_per_page_referrers_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!, $page: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        perPage(page: $page) {
          referrers {
            items {
              referrer
              count
              percentage
            }
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::PerPage::Referrers, type: :request do
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
      graphql_request(analytics_per_page_referrers_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['analytics']['perPage']['referrers']
      expect(response['items']).to eq []
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording_1) { create(:recording, site:) }
    let(:recording_2) { create(:recording, site:) }
    let(:recording_3) { create(:recording, site:) }
    let(:recording_4) { create(:recording, site:) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          referrer: 'http://google.com', 
          disconnected_at: Time.new(2021, 8, 7).to_i * 1000,
          recording_id: recording_1.id,
          visitor_id: recording_1.visitor_id,
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          referrer: 'http://google.com', 
          disconnected_at: Time.new(2021, 8, 7).to_i * 1000,
          recording_id: recording_2.id,
          visitor_id: recording_2.visitor_id,
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          referrer: nil, 
          disconnected_at: Time.new(2021, 8, 7).to_i * 1000,
          recording_id: recording_3.id,
          visitor_id: recording_3.visitor_id,
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          referrer: 'http://facebook.com', 
          disconnected_at: Time.new(2021, 8, 6).to_i * 1000,
          recording_id: recording_4.id,
          visitor_id: recording_4.visitor_id,
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
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          recording_id: recording_4.id
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
      graphql_request(analytics_per_page_referrers_query, variables, user)
    end

    it 'returns the referrers' do
      response = subject['data']['site']['analytics']['perPage']['referrers']
      expect(response['items']).to match_array([
        {
          'referrer' => 'http://google.com',
          'percentage' => 50,
          'count' => 2
        },
        {
          'referrer' => 'http://facebook.com',
          'percentage' => 25,
          'count' => 1
        },
        {
          'referrer' => 'Direct',
          'percentage' => 25,
          'count' => 1
        }
      ])
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording_1) { create(:recording, site:) }
    let(:recording_2) { create(:recording, site:) }
    let(:recording_3) { create(:recording, site:) }
    let(:recording_4) { create(:recording, site:) }
    let(:recording_5) { create(:recording, site:) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          referrer: 'http://google.com', 
          disconnected_at: Time.new(2021, 8, 7).to_i * 1000,
          recording_id: recording_1.id,
          visitor_id: recording_1.visitor_id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          referrer: nil, 
          disconnected_at: Time.new(2021, 8, 7).to_i * 1000,
          recording_id: recording_2.id,
          visitor_id: recording_2.visitor_id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          referrer: 'http://facebook.com', 
          disconnected_at: Time.new(2021, 8, 6).to_i * 1000,
          recording_id: recording_3.id,
          visitor_id: recording_3.visitor_id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          referrer: 'http://facebook.com', 
          disconnected_at: Time.new(2021, 7, 6).to_i * 1000,
          recording_id: recording_4.id,
          visitor_id: recording_4.visitor_id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          referrer: 'http://facebook.com', 
          disconnected_at: Time.new(2021, 7, 6).to_i * 1000,
          recording_id: recording_5.id,
          visitor_id: recording_5.visitor_id
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
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          recording_id: recording_4.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test',
          recording_id: recording_5.id
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
      graphql_request(analytics_per_page_referrers_query, variables, user)
    end

    it 'returns the referrers' do
      response = subject['data']['site']['analytics']['perPage']['referrers']
      expect(response['items']).to match_array([
        {
          'referrer' => 'http://google.com',
          'percentage' => 33.33,
          'count' => 1
        },
        {
          'referrer' => 'http://facebook.com',
          'percentage' => 33.33,
          'count' => 1
        },
        {
          'referrer' => 'Direct',
          'percentage' => 33.33,
          'count' => 1
        }
      ])
    end
  end
end
