# frozen_string_literal: true

require 'rails_helper'

analytics_recordings_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        recordings {
          groupType
          groupRange
          items {
            dateKey
            count
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::Recordings, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user) }

  subject do
    variables = { 
      site_id: site.id,
      from_date: '2022-10-23',
      to_date: '2022-10-30' 
    }
    graphql_request(analytics_recordings_query, variables, user)
  end
  
  context 'when there are no recordings' do
    it 'returns an empty array' do
      response = subject['data']['site']['analytics']

      expect(response['recordings']).to eq(
        'groupType' => 'daily',
        'groupRange' => 7,
        'items' => []
      )
    end
  end

  context 'when there are some recordings' do
    before do
      create(:recording, site:, connected_at: 1667028000074, disconnected_at: 1667028026074 )
      create(:recording, site:, connected_at: 1667028001074, disconnected_at: 1667028026074 )
      create(:recording, site:, connected_at: 1667028002074, disconnected_at: 1667028026074 )
      create(:recording, site:, connected_at: 1667028012074, disconnected_at: 1667028026074 )
      create(:recording, site:, connected_at: 1667028014074, disconnected_at: 1667028026074 )
    end

    it 'returns the results' do
      response = subject['data']['site']['analytics']

      expect(response['recordings']).to eq(
        'groupType' => 'daily',
        'groupRange' => 7,
        'items' => [
          {
            'count' => 5,
            'dateKey' => '302'
          }
        ]
      )
    end
  end
end
