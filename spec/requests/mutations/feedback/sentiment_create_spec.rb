# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

sentiment_create_mutation = <<-GRAPHQL
  mutation($input: SentimentCreateInput!) {
    sentimentCreate(input: $input) {
      message
    }
  }
GRAPHQL

RSpec.describe Mutations::Feedback::SentimentCreate, type: :request do
  let(:site_id) { SecureRandom.uuid }
  let(:visitor_id) { SecureRandom.base36 }
  let(:session_id) { SecureRandom.base36 }

  let(:time_now) { double(:time, to_i: 1645723427) }

  before do
    allow(Time).to receive(:now).and_return(time_now)
  end

  subject do
    variables = {
      input: {
        siteId: site_id,
        visitorId: visitor_id,
        sessionId: session_id,
        score: 5,
        comment: 'Looks alright'
      }
    }

    graphql_request(sentiment_create_mutation, variables, nil)
  end

  it 'returns the success message' do
    response = subject['data']['sentimentCreate']
    expect(response).to eq('message' => 'Sentiment score saved')
  end

  it 'adds the score to the redis list' do
    subject

    value = Cache.redis.lrange("events::#{site_id}::#{visitor_id}::#{session_id}", 0, 1)
    expect(value.first).to eq("{\"key\":\"sentiment\",\"value\":{\"type\":5,\"data\":{\"score\":5,\"comment\":\"Looks alright\"},\"timestamp\":1645723427000}}")
  end
end
