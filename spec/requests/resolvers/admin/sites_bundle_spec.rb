# frozen_string_literal: true

require 'rails_helper'

sites_bundle_sites_query = <<-GRAPHQL
  query($bundle_id: ID!) {
    admin {
      sitesBundle(bundleId: $bundle_id) {
        id
        name
        plan {
          name
        }
        sites {
          id
          name
        }
        stats {
          totalAll
          deletedAll
          totalCurrentMonth
          deletedCurrentMonth
          recordingCounts {
            siteId
            count
            dateKey
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Admin::SitesBundle, type: :request do
  let(:bundle_id) { -1 }

  subject { graphql_request(sites_bundle_sites_query, { bundle_id: }, user) }

  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      expect(subject['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser' do
    context 'and the bundle does not exist' do
      let(:user) { create(:user, superuser: true) }

      it 'raises an error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'and the bundle exist' do
      let(:user) { create(:user, superuser: true) }

      let(:bundle) { create(:site_bundle, name: 'bundle_1') }
      let(:site) { create(:site, name: 'Site 1') }

      let(:bundle_id) { bundle.id }

      let(:recordings) do
        [
          create(:recording, site:),
          create(:recording, site:, status: Recording::ANALYTICS_ONLY),
          create(:recording, site:, created_at: 2.months.ago),
          create(:recording, site:, created_at: 2.months.ago, status: Recording::ANALYTICS_ONLY)
        ]
      end

      before do
        create(:site_bundles_site, site:, site_bundle: bundle, primary: true)

        site.plan.update!(plan_id: '094f6148-22d6-4201-9c5e-20bffb68cc48')

        ClickHouse::Recording.insert do |buffer|
          recordings.each do |recording|
            buffer << {
              uuid: SecureRandom.uuid,
              site_id: recording.site.id,
              recording_id: recording.id,
              status: recording.status,
              disconnected_at: recording.created_at.to_i * 1000
            }
          end
        end
      end

      it 'returns the bundle and the sites' do
        response = subject['data']['admin']['sitesBundle']

        expect(response).to eq(
          'id' => bundle.id.to_s,
          'name' => bundle.name,
          'plan' => { 'name' => 'Light' },
          'sites' => [
            {
              'id' => site.id.to_s,
              'name' => site.name
            }
          ],
          'stats' => {
            'totalAll' => 4,
            'totalCurrentMonth' => 2,
            'deletedAll' => 2,
            'deletedCurrentMonth' => 1,
            'recordingCounts' => [
              {
                'count' => 2,
                'dateKey' => '2024/01',
                'siteId' => site.id.to_s
              },
              {
                'count' => 2,
                'dateKey' => '2023/11',
                'siteId' => site.id.to_s
              }
            ]
          }
        )
      end
    end
  end
end
