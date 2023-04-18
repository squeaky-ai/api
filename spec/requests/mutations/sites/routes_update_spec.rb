# typed: false
# frozen_string_literal: true

require 'rails_helper'

site_routes_update_mutation = <<-GRAPHQL
  mutation($input: SitesRoutesUpdateInput!) {
    routesUpdate(input: $input) {
      id
      routes
    }
  }
GRAPHQL

RSpec.describe Mutations::Sites::RoutesUpdate, type: :request do
  context 'when updating the routes' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user, routes: ['foo']) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          routes: ['bar', 'baz']
        }
      }
      graphql_request(site_routes_update_mutation, variables, user)
    end

    it 'returns the updated site' do
      expect(subject['data']['routesUpdate']['routes']).to eq(['bar', 'baz'])
    end

    it 'updates the record' do
      expect { subject }.to change { site.reload.routes }.from(['foo']).to(['bar', 'baz'])
    end
  end
end
