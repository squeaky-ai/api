# frozen_string_literal: true

require 'rails_helper'

analytics_visitors_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        visitors {
          new
          timestamp
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::Visitors, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_visitors_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['analytics']
      expect(response['visitors']).to eq []
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      visitor = create(:visitor)

      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, site: site, visitor: visitor)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, site: site, visitor: visitor)
      create(:recording, disconnected_at: Time.new(2021, 8, 5).to_i * 1000, site: site)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_visitors_query, variables, user)
    end

    it 'returns the visitors' do
      response = subject['data']['site']['analytics']
      expect(response['visitors']).to match_array([
        {
          'new' => false,
          'timestamp' => '2021-08-06T23:00:00+00:00'
        },
        {
          'new' => false,
          'timestamp' => '2021-08-05T23:00:00+00:00'
        },
        {
          'new' => true,
          'timestamp' => '2021-08-04T23:00:00+00:00'
        }
      ])
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      visitor = create(:visitor)

      create(:recording, disconnected_at: Time.new(2021, 8, 7).to_i * 1000, site: site, visitor: visitor)
      create(:recording, disconnected_at: Time.new(2021, 8, 6).to_i * 1000, site: site, visitor: visitor)
      create(:recording, disconnected_at: Time.new(2021, 8, 5).to_i * 1000, site: site)
      create(:recording, disconnected_at: Time.new(2021, 7, 5).to_i * 1000, site: site)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_visitors_query, variables, user)
    end

    it 'returns the visitors' do
      response = subject['data']['site']['analytics']
      expect(response['visitors']).to match_array([
        {
          'new' => false,
          'timestamp' => '2021-08-06T23:00:00+00:00'
        },
        {
          'new' => false,
          'timestamp' => '2021-08-05T23:00:00+00:00'
        },
        {
          'new' => true,
          'timestamp' => '2021-08-04T23:00:00+00:00'
        }
      ])
    end
  end
end
