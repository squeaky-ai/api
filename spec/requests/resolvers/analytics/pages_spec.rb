# frozen_string_literal: true

require 'rails_helper'

analytics_pages_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        pages {
          path
          count
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::Pages, type: :request do
  context 'when there are no recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_pages_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['analytics']
      expect(response['pages']).to eq []
    end
  end

  context 'when there are some recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ disconnected_at: Time.new(2021, 8, 7).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: create_visitor)
      create_recording({ disconnected_at: Time.new(2021, 8, 6).to_i * 1000, pages: [create_page(url: '/'), create_page(url: '/test')] }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_pages_query, variables, user)
    end

    it 'returns the pages' do
      response = subject['data']['site']['analytics']
      expect(response['pages']).to eq(
        [
          {
            'path' => '/',
            'count' => 2
          },
          {
            'path' => '/test',
            'count' => 1
          }
        ]
      )
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ disconnected_at: Time.new(2021, 8, 7).to_i * 1000, pages: [create_page(url: '/')] }, site: site, visitor: create_visitor)
      create_recording({ disconnected_at: Time.new(2021, 8, 6).to_i * 1000, pages: [create_page(url: '/'), create_page(url: '/test')] }, site: site, visitor: create_visitor)
      create_recording({ disconnected_at: Time.new(2021, 7, 6).to_i * 1000, pages: [create_page(url: '/contact')] }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_pages_query, variables, user)
    end

    it 'returns the pages' do
      response = subject['data']['site']['analytics']
      expect(response['pages']).to eq(
        [
          {
            'path' => '/',
            'count' => 2
          },
          {
            'path' => '/test',
            'count' => 1
          }
        ]
      )
    end
  end
end