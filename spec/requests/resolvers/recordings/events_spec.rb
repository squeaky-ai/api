# frozen_string_literal: true

require 'rails_helper'

site_recording_events_query = <<-GRAPHQL
  query($site_id: ID!, $recording_id: ID!) {
    site(siteId: $site_id) {
      recording(recordingId: $recording_id) {
        id
        events {
          items {
            id
            data
            type
            timestamp
          }
          pagination {
            currentPage
            totalPages
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Recordings::Events, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user) }
  let(:recording) { create(:recording, site:) }

  let(:list_objects_v2) do
    double(contents: [
      {
        key: "#{site.uuid}/#{recording.visitor.visitor_id}/#{recording.session_id}/1.json"
      }
    ])
  end

  let(:get_object) do
    data = { href: 'http://localhost/', width: 0, height: 0 }
    events = [
      {
        id: SecureRandom.uuid,
        type: Event::META,
        data:,
        timestamp: 1625389200000
      }
    ]
    double(body: double(read: events.to_json))
  end

  let(:s3_client) { instance_double(Aws::S3::Client, list_objects_v2:, get_object:) }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
  end

  subject do
    variables = { site_id: site.id, recording_id: recording.id }
    graphql_request(site_recording_events_query, variables, user)
  end

  it 'returns the item with the events' do
    response = subject['data']['site']['recording']
    expect(response['events']['items'].size).to eq 1
  end

  it 'returns the correct pagination' do
    response = subject['data']['site']['recording']
    expect(response['events']['pagination']).to eq(
      'currentPage' => 1,
      'totalPages' => 1
    )
  end
end
