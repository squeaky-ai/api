# frozen_string_literal: true

require 'rails_helper'

sentiment_response_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!, $page: Int, $size: Int, $sort: FeedbackSentimentResponseSort) {
    site(siteId: $site_id) {
      sentiment(fromDate: $from_date, toDate: $to_date) {
        responses(page: $page, size: $size, sort: $sort) {
          items {
            id
            score
            comment
            visitor {
              id
              visitorId
            }
            sessionId
            recordingId
            timestamp
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

RSpec.describe Resolvers::Feedback::SentimentResponse, type: :request do
  context 'when there is no data' do
    let(:user) { create(:user) }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(sentiment_response_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['sentiment']
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
    let(:site) { create_site_and_team(user: user) }
    let(:visitor) { create_visitor }

    before do
      create_sentiment({ score: 5, created_at: Time.new(2021, 8, 4) }, recording: create_recording(site: site, visitor: visitor))
      create_sentiment({ score: 3, created_at: Time.new(2021, 8, 3) }, recording: create_recording(site: site, visitor: visitor))
      create_sentiment({ score: 3, created_at: Time.new(2020, 8, 2) }, recording: create_recording(site: site, visitor: visitor))
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(sentiment_response_query, variables, user)
    end

    it 'returns the data' do
      response = subject['data']['site']['sentiment']
      expect(response['responses']['items'].size).to eq 2
      expect(response['responses']['pagination']).to eq(
        'pageSize' => 10,
        'total' => 2,
        'sort' => 'timestamp__desc'
      )
    end

    it 'returns in descending order' do
      response = subject['data']['site']['sentiment']
      items = response['responses']['items'].map { |i| i['timestamp'] }
      expect(items).to eq(['2021-08-03T23:00:00Z', '2021-08-02T23:00:00Z'])
    end
  end

  context 'when requesting in ascending order' do
    let(:user) { create(:user) }
    let(:site) { create_site_and_team(user: user) }
    let(:visitor) { create_visitor }

    before do
      create_sentiment({ score: 5, created_at: Time.new(2021, 8, 4) }, recording: create_recording(site: site, visitor: visitor))
      create_sentiment({ score: 3, created_at: Time.new(2021, 8, 3) }, recording: create_recording(site: site, visitor: visitor))
      create_sentiment({ score: 3, created_at: Time.new(2020, 8, 2) }, recording: create_recording(site: site, visitor: visitor))
    end

    subject do
      variables = { 
        site_id: site.id, 
        from_date: '2021-08-01', 
        to_date: '2021-08-08',
        sort: 'timestamp__asc'
      }
      graphql_request(sentiment_response_query, variables, user)
    end

    it 'returns in ascending order' do
      response = subject['data']['site']['sentiment']
      items = response['responses']['items'].map { |i| i['timestamp'] }
      expect(items).to eq(['2021-08-02T23:00:00Z', '2021-08-03T23:00:00Z'])
    end
  end
end
