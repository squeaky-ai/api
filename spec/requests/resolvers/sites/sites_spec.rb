# frozen_string_literal: true

require 'rails_helper'

sites_query = <<-GRAPHQL
  query {
    sites {
      id
      name
      url
      ownerName
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
GRAPHQL

RSpec.describe Resolvers::Sites::Sites, type: :request do
  context 'when there is no current_user' do
    let(:site) { create(:site) }

    it 'raises an error' do
      response = graphql_request(sites_query, {}, nil)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is not a member of any sites' do
    let(:user) { create(:user) }

    it 'returns an empty array' do
      response = graphql_request(sites_query, {}, user)

      expect(response['data']['sites']).to eq []
    end
  end

  context 'when the user is a member of a site' do
    let(:user) { create(:user) }
    let!(:site) { create(:site_with_team, owner: user) }

    it 'returns the list of sites' do
      response = graphql_request(sites_query, {}, user)

      expect(response['data']['sites']).to eq(
        [
          {
            'id' => site.id.to_s,
            'name' => site.name,
            'url' => site.url,
            'ownerName' => "#{user.first_name} #{user.last_name}",
            'plan' => {
              'planId' => site.plan.plan_id,
              'name' => site.plan.name
            },
            'uuid' => site.uuid,
            'verifiedAt' => {
              'iso8601' => site.verified_at.iso8601
            },
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

  context 'when the user has a pending invite' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team) }

    before do
      create(:team, user:, site:, role: Team::MEMBER, status: Team::PENDING)
    end

    it 'does not return the site' do
      response = graphql_request(sites_query, {}, user)

      expect(response['data']['sites']).to eq([])
    end
  end
end
