# typed: false
# frozen_string_literal: true

require 'rails_helper'

nps_scores_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      nps(fromDate: $from_date, toDate: $to_date) {
        scores {
          trend
          score
          responses {
            score
            timestamp {
              iso8601
            }
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Feedback::NpsScores, type: :request do
  context 'when there is no data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(nps_scores_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['nps']
      expect(response['scores']).to eq(
        'trend' => 0,
        'score' => 0,
        'responses' => []
      )
    end
  end

  context 'when there is some data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:visitor) { create(:visitor) }

    before do
      create(:nps, score: 9, created_at: Time.new(2021, 8, 3), recording: create(:recording, site: site, visitor: visitor))
      create(:nps, score: 3, created_at: Time.new(2021, 8, 3), recording: create(:recording, site: site, visitor: visitor))
      create(:nps, score: 3, created_at: Time.new(2020, 8, 3), recording: create(:recording, site: site, visitor: visitor))
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(nps_scores_query, variables, user)
    end

    it 'returns the data' do
      response = subject['data']['site']['nps']
      expect(response['scores']).to eq(
        'trend' => 0,
        'score' => 0,
        'responses' => [
          {
            'score' => 9,
            'timestamp' => {
              'iso8601' => '2021-08-02T23:00:00Z'
            }
          },
          {
            'score' => 3,
            'timestamp' => {
              'iso8601' => '2021-08-02T23:00:00Z'
            }
          }
        ]
      )
    end
  end
end
