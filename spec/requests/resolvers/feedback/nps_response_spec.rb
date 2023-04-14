# typed: false
# frozen_string_literal: true

require 'rails_helper'

nps_response_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!, $page: Int, $size: Int, $sort: FeedbackNpsResponseSort) {
    site(siteId: $site_id) {
      nps(fromDate: $from_date, toDate: $to_date) {
        responses(page: $page, size: $size, sort: $sort) {
          items {
            id
            score
            comment
            contact
            visitor {
              id
              visitorId
            }
            sessionId
            recordingId
            timestamp {
              iso8601
            }
          }
          pagination {
            pageSize
            total
            sort
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Feedback::NpsResponse, type: :request do
  context 'when there is no data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(nps_response_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['nps']
      expect(response['responses']).to eq(
        'items' => [],
        'pagination' => {
          'pageSize' => 10,
          'total' => 0,
          'sort' => 'timestamp__desc'
        }
      )
    end
  end

  context 'when there is some data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:visitor) { create(:visitor) }

    before do
      create(:nps, score: 5, created_at: Time.new(2021, 8, 4), recording: create(:recording, site: site, visitor: visitor))
      create(:nps, score: 3, created_at: Time.new(2021, 8, 3), recording: create(:recording, site: site, visitor: visitor))
      create(:nps, score: 3, created_at: Time.new(2020, 8, 3), recording: create(:recording, site: site, visitor: visitor))
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(nps_response_query, variables, user)
    end

    it 'returns the data' do
      response = subject['data']['site']['nps']
      expect(response['responses']['items'].size).to eq 2
      expect(response['responses']['pagination']).to eq(
        'pageSize' => 10,
        'total' => 2,
        'sort' => 'timestamp__desc'
      )
    end

    it 'returns in descending order' do
      response = subject['data']['site']['nps']
      items = response['responses']['items'].map { |i| i['timestamp']['iso8601'] }
      expect(items).to eq(['2021-08-03T23:00:00Z', '2021-08-02T23:00:00Z'])
    end
  end

  context 'when requesting in ascending order' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:visitor) { create(:visitor) }

    before do
      create(:nps, score: 5, created_at: Time.new(2021, 8, 4), recording: create(:recording, site: site, visitor: visitor))
      create(:nps, score: 3, created_at: Time.new(2021, 8, 3), recording: create(:recording, site: site, visitor: visitor))
      create(:nps, score: 3, created_at: Time.new(2020, 8, 2), recording: create(:recording, site: site, visitor: visitor))
    end

    subject do
      variables = { 
        site_id: site.id, 
        from_date: '2021-08-01', 
        to_date: '2021-08-08',
        sort: 'timestamp__asc'
      }
      graphql_request(nps_response_query, variables, user)
    end

    it 'returns in ascending order' do
      response = subject['data']['site']['nps']
      items = response['responses']['items'].map { |i| i['timestamp']['iso8601'] }
      expect(items).to eq(['2021-08-02T23:00:00Z', '2021-08-03T23:00:00Z'])
    end
  end
end
