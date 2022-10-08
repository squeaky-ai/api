# frozen_string_literal: true

require 'rails_helper'

sites_admin_query = <<-GRAPHQL
  query {
    admin {
      sitesBundles {
        name
        plan {
          name
        }
        sites {
          name
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Admin::SitesBundles, type: :request do
  subject { graphql_request(sites_admin_query, {}, user) }

  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      expect(subject['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser' do
    context 'and there are no bundles' do
      let(:user) { create(:user, superuser: true) }

      it 'returns an empty array' do
        response = subject['data']['admin']['sitesBundles']

        expect(response).to eq([])
      end
    end

    context 'and there are some bundles' do
      let(:user) { create(:user, superuser: true) }

      before do
        bundle_1 = create(:site_bundle, name: 'bundle_1')
        bundle_2 = create(:site_bundle, name: 'bundle_2')

        site_1 = create(:site, name: 'Site 1')
        site_2 = create(:site, name: 'Site 2')

        create(:site_bundles_site, site: site_1, site_bundle: bundle_1, primary: true)
        create(:site_bundles_site, site: site_2, site_bundle: bundle_2, primary: true)
        
        site_2.plan.update!(tier: 1)
      end

      it 'returns all the bundles' do
        response = subject['data']['admin']['sitesBundles']

        expect(response).to match_array([
          {
            'name' => 'bundle_1',
            'plan' => {
              'name' => 'Free'
            },
            'sites' => [
              {
                'name' => 'Site 1'
              }
            ]
          },
          {
            'name' => 'bundle_2',
            'plan' => {
              'name' => 'Light'
            },
            'sites' => [
              {
                'name' => 'Site 2'
              }
            ]
          }
        ])
      end
    end
  end
end
