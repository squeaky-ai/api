# frozen_string_literal: true

require 'rails_helper'

analytics_per_page_visits_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!, $page: String!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        perPage(page: $page) {
          visitsAt {
            day
            hour
            count
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::PerPage::VisitsAt, type: :request do
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
      graphql_request(analytics_per_page_visits_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['analytics']['perPage']
      expect(response['visitsAt']).to eq []
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      visitor = create(:visitor)

      page_1 = create(:page, url: '/')
      page_2 = create(:page, url: '/')
      page_3 = create(:page, url: '/')
      page_4 = create(:page, url: '/test')

      create(:recording, pages: [page_1], disconnected_at: Time.new(2021, 8, 7, 3, 0, 0).to_i * 1000, site: site, visitor: visitor)
      create(:recording, pages: [page_2], disconnected_at: Time.new(2021, 8, 6, 16, 0, 0).to_i * 1000, site: site, visitor: visitor)
      create(:recording, pages: [page_3], disconnected_at: Time.new(2021, 8, 6, 16, 0, 0).to_i * 1000, site: site, visitor: visitor)
      create(:recording, pages: [page_4], disconnected_at: Time.new(2021, 8, 5, 9, 0, 0).to_i * 1000, site: site)
    end

    subject do
      variables = {
        site_id: site.id,
        from_date: '2021-08-01',
        to_date: '2021-08-08',
        page: '/'
      }
      graphql_request(analytics_per_page_visits_query, variables, user)
    end

    it 'returns the visitors' do
      response = subject['data']['site']['analytics']['perPage']
      expect(response['visitsAt']).to match_array(
        [
          {
            'count' => 1, 
            'day' => 'Thu', 
            'hour' => 8
          },
          {
            'count' => 4,
            'day' => 'Fri',
            'hour' => 15
          }, 
          {
            'count' => 2,
            'day' => 'Sat',
            'hour' => 2
          }
        ]
      )
    end
  end
end
