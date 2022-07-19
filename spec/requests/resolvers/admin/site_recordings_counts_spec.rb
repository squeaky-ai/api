# frozen_string_literal: true

require 'rails_helper'

site_admin_recordings_counts_query = <<-GRAPHQL
  query($site_id: ID!) {
    admin {
      site(siteId: $site_id) {
        id
        recordingCounts {
          total
          locked
          deleted
          currentMonth
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Admin::SiteRecordingsCounts, type: :request do
  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      variables = { site_id: 345345345 }
      response = graphql_request(site_admin_recordings_counts_query, variables, user)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser' do
    let(:user) { create(:user, superuser: true) }
    let!(:site) { create(:site) }

    it 'returns empty counts' do
      variables = { site_id: site.id }
      response = graphql_request(site_admin_recordings_counts_query, variables, user)

      expect(response['data']['admin']['site']['recordingCounts']).to eq(
        'total' => 0,
        'locked' => 0,
        'deleted' => 0,
        'currentMonth' => 0
      )
    end

    context 'when there are some recordings' do
      let(:user) { create(:user, superuser: true) }
      let!(:site) { create(:site) }

      before do
        create(:recording, site:)
        create(:recording, site:, status: Recording::LOCKED)
        create(:recording, site:, status: Recording::LOCKED)
        create(:recording, site:, status: Recording::DELETED)
        create(:recording, site:, created_at: Time.now - 2.months)
      end

      it 'returns the counts' do
        variables = { site_id: site.id }
        response = graphql_request(site_admin_recordings_counts_query, variables, user)

        expect(response['data']['admin']['site']['recordingCounts']).to eq(
          'total' => 5,
          'locked' => 2,
          'deleted' => 1,
          'currentMonth' => 4
        )
      end
    end
  end
end
