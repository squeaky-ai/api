# frozen_string_literal: true

require 'rails_helper'

site_recording_latest_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      recordingLatest {
        id
        siteId
        language
        duration
        pageViews
        pageCount
        startPage
        exitPage
        device {
          browserName
          browserDetails
          viewportX
          viewportY
          deviceX
          deviceY
          deviceType
          useragent
        }
        visitor {
          id
          visitorId
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Recordings::Latest, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_recording_latest_query, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['site']['recordingLatest']
      expect(response).to be nil
    end
  end

  context 'when the recording does exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let!(:recording) { create(:recording, site:) }

    before do
      ClickHouse::Recording.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
          disconnected_at: recording[:disconnected_at]
        }
      end
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_recording_latest_query, variables, user)
    end

    it 'returns the item' do
      response = subject['data']['site']['recordingLatest']
      expect(response).not_to be nil
    end
  end
end
