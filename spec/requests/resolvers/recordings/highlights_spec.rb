# frozen_string_literal: true

require 'rails_helper'

site_recordings_highlights_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      recordingsHighlights(fromDate: $from_date, toDate: $to_date) {
        eventful {
          id
        }
        longest {
          id
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Recordings::Highlights, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user) }

  subject do
    variables = { 
      site_id: site.id, 
      from_date: '2022-10-24',
      to_date: '2022-10-30'
    }
    graphql_request(site_recordings_highlights_query, variables, user)
  end

  context 'when there are no recordings' do
    it 'returns no results' do
      expect(subject['data']['site']['recordingsHighlights']).to eq(
        'eventful' => [],
        'longest' => []
      )
    end
  end

  context 'when there are some recordings' do
    let!(:eventful_recording_1) { create(:recording, site:, disconnected_at: 1667028026074, active_events_count: 20 )}
    let!(:eventful_recording_2) { create(:recording, site:, disconnected_at: 1667028026074, active_events_count: 16 )}
    let!(:eventful_recording_3) { create(:recording, site:, disconnected_at: 1667028026074, active_events_count: 13 )}
    let!(:eventful_recording_4) { create(:recording, site:, disconnected_at: 1667028026074, active_events_count: 10 )}
    let!(:eventful_recording_5) { create(:recording, site:, disconnected_at: 1667028026074, active_events_count: 3 )}

    let!(:long_recording_1) { create(:recording, site:, connected_at: 1667028000074, disconnected_at: 1667028026074 )}
    let!(:long_recording_2) { create(:recording, site:, connected_at: 1667028001074, disconnected_at: 1667028026074 )}
    let!(:long_recording_3) { create(:recording, site:, connected_at: 1667028002074, disconnected_at: 1667028026074 )}
    let!(:long_recording_4) { create(:recording, site:, connected_at: 1667028012074, disconnected_at: 1667028026074 )}
    let!(:long_recording_5) { create(:recording, site:, connected_at: 1667028014074, disconnected_at: 1667028026074 )}

    it 'returns the results' do
      expect(subject['data']['site']['recordingsHighlights']).to eq(
        'eventful' => [
          {
            'id' => eventful_recording_1.id.to_s
          },
          {
            'id' => eventful_recording_2.id.to_s
          },
          {
            'id' => eventful_recording_3.id.to_s
          },
          {
            'id' => eventful_recording_4.id.to_s
          },
          {
            'id' => eventful_recording_5.id.to_s
          }
        ],
        'longest' => [
          {
            'id' => long_recording_1.id.to_s
          },
          {
            'id' => long_recording_2.id.to_s
          },
          {
            'id' => long_recording_3.id.to_s
          },
          {
            'id' => long_recording_4.id.to_s
          },
          {
            'id' => long_recording_5.id.to_s
          }
        ]
      )
    end
  end
end
