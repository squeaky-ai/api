# frozen_string_literal: true

require 'rails_helper'

nps_ratings_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!) {
    site(siteId: $site_id) {
      nps(fromDate: $from_date, toDate: $to_date) {
        ratings {
          score
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Feedback::NpsRatings, type: :request do
  context 'when there is no data' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(nps_ratings_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['nps']
      expect(response['ratings']).to eq([])
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
      graphql_request(nps_ratings_query, variables, user)
    end

    it 'returns the data' do
      response = subject['data']['site']['nps']
      expect(response['ratings']).to eq([
        {
          'score' => 9
        },
        {
          'score' => 3
        }
      ])
    end
  end
end
