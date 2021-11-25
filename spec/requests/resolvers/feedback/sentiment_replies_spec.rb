# frozen_string_literal: true

require 'rails_helper'

sentiment_replies_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!) {
    site(siteId: $site_id) {
      sentiment(fromDate: $from_date, toDate: $to_date) {
        replies {
          total
          responses {
            score
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Feedback::SentimentReplies, type: :request do
  context 'when there is no data' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(sentiment_replies_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['sentiment']
      expect(response['replies']).to eq(
        'total' => 0,
        'responses' => []
      )
    end
  end

  context 'when there is some data' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:visitor) { create_visitor }

    before do
      create_sentiment({ score: 5, created_at: Time.new(2021, 8, 3) }, recording: create_recording(site: site, visitor: visitor))
      create_sentiment({ score: 3, created_at: Time.new(2021, 8, 3) }, recording: create_recording(site: site, visitor: visitor))
      create_sentiment({ score: 3, created_at: Time.new(2020, 8, 3) }, recording: create_recording(site: site, visitor: visitor))
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(sentiment_replies_query, variables, user)
    end

    it 'returns the data' do
      response = subject['data']['site']['sentiment']
      expect(response['replies']).to eq(
        'total' => 2,
        'responses' => [
          {
            'score' => 5
          },
          {
            'score' => 3
          }
        ]
      )
    end
  end
end
