# frozen_string_literal: true

require 'rails_helper'

analytics_referrers_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        referrers {
          name
          count
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::Referrers, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_referrers_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['analytics']
      expect(response['referrers']).to eq []
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create_recording({ referrer: 'http://google.com', disconnected_at: Time.new(2021, 8, 7).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: create_visitor)
      create_recording({ referrer: 'http://google.com', disconnected_at: Time.new(2021, 8, 7).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: create_visitor)
      create_recording({ referrer: 'http://facebook.com', disconnected_at: Time.new(2021, 8, 6).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_referrers_query, variables, user)
    end

    it 'returns the referrers' do
      response = subject['data']['site']['analytics']
      expect(response['referrers']).to match_array([
        {
          'name' => 'http://facebook.com',
          'count' => 1
        },
        {
          'name' => 'http://google.com',
          'count' => 2
        }
      ])
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create_recording({ referrer: 'http://google.com', disconnected_at: Time.new(2021, 8, 7).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: create_visitor)
      create_recording({ referrer: 'http://facebook.com', disconnected_at: Time.new(2021, 8, 6).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: create_visitor)
      create_recording({ referrer: 'http://facebook.com', disconnected_at: Time.new(2021, 7, 6).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_referrers_query, variables, user)
    end

    it 'returns the referrers' do
      response = subject['data']['site']['analytics']
      expect(response['referrers']).to match_array([
        {
          'name' => 'http://google.com',
          'count' => 1
        },
        {
          'name' => 'http://facebook.com',
          'count' => 1
        }
      ])
    end
  end
end
