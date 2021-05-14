# frozen_string_literal: true

require 'rails_helper'

sites_query = <<-GRAPHQL
  query {
    sites {
      id
      name
      url
      ownerName
      plan
      planName
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

RSpec.describe 'QuerySites', type: :request do
  context 'when there is no current_user' do
    let(:site) { create_site }

    it 'raises an error' do
      response = graphql_request(sites_query, {}, nil)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is not a member of any sites' do
    let(:user) { create_user }

    it 'returns an empty array' do
      response = graphql_request(sites_query, {}, user)

      expect(response['data']['sites']).to eq []
    end
  end

  context 'when the user is a member of a site' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before { site }

    it 'returns the list of sites' do
      response = graphql_request(sites_query, {}, user)

      expect(response['data']['sites']).to eq(
        [
          {
            'id' => site.id.to_s,
            'name' => site.name,
            'url' => site.url,
            'ownerName' => "#{user.first_name} #{user.last_name}",
            'plan' => site.plan,
            'planName' => site.plan_name,
            'uuid' => site.uuid,
            'verifiedAt' => nil,
            'team' => [
              {
                'id' => site.team[0].id.to_s,
                'role' => site.team[0].role,
                'status' => site.team[0].status,
                'user' => {
                  'id' => user.id.to_s,
                  'firstName' => user.first_name,
                  'lastName' => user.last_name
                }
              }
            ]
          }
        ]
      )
    end
  end
end