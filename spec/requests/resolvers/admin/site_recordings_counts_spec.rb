# frozen_string_literal: true

require 'rails_helper'

site_admin_recordings_counts_query = <<-GRAPHQL
  query($site_id: ID!) {
    admin {
      site(siteId: $site_id) {
        id
        recordingCounts {
          totalAll
          deletedAll
          totalCurrentMonth
          deletedCurrentMonth
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
        'totalAll' => 0,
        'deletedAll' => 0,
        'totalCurrentMonth' => 0,
        'deletedCurrentMonth' => 0
      )
    end

    context 'when there are some recordings' do
      let(:user) { create(:user, superuser: true) }
      let!(:site) { create(:site) }

      before do
        create(:recording, site:)
        create(:recording, site:, status: Recording::ANALYTICS_ONLY)
        create(:recording, site:, created_at: 2.months.ago)
        create(:recording, site:, created_at: 2.months.ago, status: Recording::ANALYTICS_ONLY)
      end

      it 'returns the counts' do
        variables = { site_id: site.id }
        response = graphql_request(site_admin_recordings_counts_query, variables, user)

        expect(response['data']['admin']['site']['recordingCounts']).to eq(
          'totalAll' => 4,
          'deletedAll' => 2,
          'totalCurrentMonth' => 2,
          'deletedCurrentMonth' => 1
        )
      end
    end
  end
end
