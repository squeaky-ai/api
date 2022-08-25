# frozen_string_literal: true

require 'rails_helper'

site_pages_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      pages(fromDate: $from_date, toDate: $to_date) {
        url
        count
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::Pages, type: :request do
  context 'when there are no pages' do
    let(:now) { Time.now }
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        site_id: site.id,
        from_date: (now - 3.days).strftime('%Y-%m-%d'),
        to_date: (now + 4.days).strftime('%Y-%m-%d')
      }
      graphql_request(site_pages_query, variables, user)
    end

    it 'returns no pages' do
      response = subject['data']['site']['pages']
      expect(response).to eq []
    end
  end

  context 'when there are some pages' do
    let(:now) { Time.now }
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, page_urls: ['/', '/test'], site:)
      create(:recording, page_urls: ['/', '/foo', '/bar'], site:)
    end

    subject do
      variables = {
        site_id: site.id,
        from_date: (now - 3.days).strftime('%Y-%m-%d'),
        to_date: (now + 4.days).strftime('%Y-%m-%d')
      }
      graphql_request(site_pages_query, variables, user)
    end

    it 'returns the pages' do
      response = subject['data']['site']['pages']
      expect(response).to match_array(
        [
          {
            'url' => '/',
            'count' => 2
          },
          {
            'url' => '/test',
            'count' => 1
          },
          {
            'url' => '/foo',
            'count' => 1
          },
          {
            'url' => '/bar',
            'count' => 1
          }
        ]
      )
    end
  end
end
