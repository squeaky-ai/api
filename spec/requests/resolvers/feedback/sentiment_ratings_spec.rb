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
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

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
end
