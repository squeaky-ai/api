# frozen_string_literal: true

require 'rails_helper'

sites_admin_query = <<-GRAPHQL
  query {
    sitesAdmin {
      id
      name
      url
      plan {
        type
        name
      }
      uuid
      verifiedAt
      team {
        id
        role
        status
        user {
          id
          firstName
          lastName
        }
      }
    }
  }
GRAPHQL

RSpec.describe 'QuerySitesAdmin', type: :request do
  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      response = graphql_request(sites_admin_query, {}, user)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser' do
    let(:user) { create(:user, superuser: true) }

    before do
      create(:site)
      create(:site)
    end

    it 'returns all the sites' do
      response = graphql_request(sites_admin_query, {}, user)

      expect(response['data']['sitesAdmin'].size).to eq 2
    end
  end
end
