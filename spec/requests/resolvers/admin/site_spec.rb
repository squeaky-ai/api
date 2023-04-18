# frozen_string_literal: true

require 'rails_helper'

site_admin_query = <<-GRAPHQL
  query($site_id: ID!) {
    admin {
      site(siteId: $site_id) {
        id
        name
        url
        plan {
          planId
          name
        }
        uuid
        verifiedAt {
          iso8601
        }
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
  }
GRAPHQL

RSpec.describe Resolvers::Admin::Site, type: :request do
  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      variables = { site_id: 345345345 }
      response = graphql_request(site_admin_query, variables, user)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser' do
    let(:user) { create(:user, superuser: true) }
    let!(:site) { create(:site) }

    it 'returns all the sites' do
      variables = { site_id: site.id }
      response = graphql_request(site_admin_query, variables, user)

      expect(response['data']['admin']['site']['id']).to eq site.id.to_s
    end
  end
end
