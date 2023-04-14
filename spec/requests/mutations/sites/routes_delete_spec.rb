# typed: false
# frozen_string_literal: true

require 'rails_helper'

site_routes_delete_mutation = <<-GRAPHQL
  mutation($input: SitesRoutesDeleteInput!) {
    routesDelete(input: $input) {
      id
      routes
    }
  }
GRAPHQL

RSpec.describe Mutations::Sites::RoutesDelete, type: :request do
  context 'when deleting a route that does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          route: 'foo' 
        }
      }
      graphql_request(site_routes_delete_mutation, variables, user)
    end

    it 'returns the original site' do
      expect(subject['data']['routesDelete']['routes']).to eq([])
    end

    it 'does not update the record' do
      expect { subject }.not_to change { site.reload.routes.size }
    end
  end

  context 'when deleting a route that does exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      site.routes << 'foo'
      site.save
    end

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          route: 'foo' 
        }
      }
      graphql_request(site_routes_delete_mutation, variables, user)
    end

    it 'returns the updated site' do
      expect(subject['data']['routesDelete']['routes']).to eq([])
    end

    it 'updates the record' do
      expect { subject }.to change { site.reload.routes.size }.from(1).to(0)
    end
  end
end
