# frozen_string_literal: true

require 'rails_helper'

nps_replies_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!) {
    site(siteId: $site_id) {
      nps(fromDate: $from_date, toDate: $to_date) {
        replies {
          trend
          responses {
            timestamp
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Feedback::NpsReplies, type: :request do
  context 'when there is no data' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(nps_replies_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['nps']
      expect(response['replies']).to eq(
        'trend' => 0,
        'responses' => []
      )
    end
  end

  context 'when there is some data' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:visitor) { create_visitor }

    before do
      create_nps({ score: 9, created_at: Time.new(2021, 8, 3) }, recording: create_recording(site: site, visitor: visitor))
      create_nps({ score: 3, created_at: Time.new(2021, 8, 3) }, recording: create_recording(site: site, visitor: visitor))
      create_nps({ score: 3, created_at: Time.new(2020, 8, 3) }, recording: create_recording(site: site, visitor: visitor))
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(nps_replies_query, variables, user)
    end

    it 'returns the data' do
      response = subject['data']['site']['nps']
      expect(response['replies']).to eq(
        'trend' => 2,
        'responses' => [
          {
            'timestamp' => '2021-08-02T23:00:00Z'
          },
          {
            'timestamp' => '2021-08-02T23:00:00Z'
          }
        ]
      )
    end
  end
end