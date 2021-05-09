# frozen_string_literal: true

require 'rails_helper'

site_query = <<-GRAPHQL
  query($id: ID!) {
    site(id: $id) {
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

RSpec.describe 'Query Site', type: :request do
  context 'when there is no current_user' do
    let(:site) { create_site }

    it 'raises an error' do
      response = graphql_query(site_query, { id: site.id }, nil)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the site does not exist' do
    let(:user) { create_user }

    it 'returns nil' do
      response = graphql_query(site_query, { id: Faker::Number.number }, user)

      expect(response['data']['site']).to be_nil
    end
  end

  context 'when the site does exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user) }

    it 'returns the site' do
      response = graphql_query(site_query, { id: site.id }, user)

      expect(response['data']['site']).to eq(
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
      )
    end
  end
end
