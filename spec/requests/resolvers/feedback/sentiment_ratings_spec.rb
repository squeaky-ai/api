# frozen_string_literal: true

require 'rails_helper'

sentiment_ratings_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!) {
    site(siteId: $site_id) {
      sentiment(fromDate: $from_date, toDate: $to_date) {
        ratings {
          score
          trend
          responses {
            score
            timestamp
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Feedback::SentimentRatings, type: :request do
  context 'when there is no data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(sentiment_ratings_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['sentiment']
      expect(response['ratings']).to eq(
        'score' => 0.0,
        'trend' => 0.0,
        'responses' => []
      )
    end
  end

  context 'when there is some data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:visitor) { create_visitor }

    before do
      create(:sentiment, score: 5, created_at: Time.new(2021, 8, 3), recording: create_recording(site: site, visitor: visitor))
      create(:sentiment, score: 3, created_at: Time.new(2021, 8, 4), recording: create_recording(site: site, visitor: visitor))
      create(:sentiment, score: 3, created_at: Time.new(2020, 8, 3), recording: create_recording(site: site, visitor: visitor))
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(sentiment_ratings_query, variables, user)
    end

    it 'returns the data' do
      response = subject['data']['site']['sentiment']
      expect(response['ratings']).to match_array(
        'score' => 4.0,
        'trend' => 4.0,
        'responses' => [
          {
            'score' => 5,
            'timestamp' => '2021-08-02T23:00:00Z'
          },
          {
            'score' => 3,
            'timestamp' => '2021-08-03T23:00:00Z'
          }
        ]
      )
    end
  end
end
