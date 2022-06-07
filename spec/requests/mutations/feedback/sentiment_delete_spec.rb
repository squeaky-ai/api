# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

sentiment_delete_mutation = <<-GRAPHQL
  mutation($input: SentimentDeleteInput!) {
    sentimentDelete(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Feedback::SentimentDelete, type: :request do
  context 'when the feedback does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        input: {
          siteId: site.id,
          sentimentId: SecureRandom.uuid
        }
      }
      graphql_request(sentiment_delete_mutation, variables, user)
    end

    it 'returns an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Sentiment response not found'
    end
  end

  context 'when the feedback does exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site) }
    let!(:sentiment) { create(:sentiment, recording: recording) }

    subject do
      variables = {
        input: {
          siteId: site.id,
          sentimentId: sentiment.id
        }
      }
      graphql_request(sentiment_delete_mutation, variables, user)
    end

    it 'deletes the sentiment' do
      expect { subject }.to change { site.reload.sentiments.size }.from(1).to(0)
    end
  end
end
