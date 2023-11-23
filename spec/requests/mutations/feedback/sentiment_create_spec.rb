# frozen_string_literal: true

require 'rails_helper'

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

  let(:time_now) { Time.new(2022, 6, 29).utc }

  before do
    allow(Time).to receive(:current).and_return(time_now)
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

    encoded_output = <<~TEXT
      eJwljEEKgDAQA78iOfegYivsG/zEokVFa8WugpT+Xas5TGAIiVjsDUKwm8zu
      BRQuXk8LipB7f1srDCycRej98Zveu29N6LxfQsHrMY+TICnknyDsdlBltGl0
      W5c5KT2/sCMg
    TEXT

    value = Cache.redis.lrange("events::#{site_id}::#{visitor_id}::#{session_id}", 0, 1)
    expect(value.first).to eq(encoded_output)
  end
end
