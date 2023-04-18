# frozen_string_literal: true

require 'rails_helper'

plan_query = <<-GRAPHQL
  query($site_id: ID) {
    plans(siteId: $site_id) {
      id
      name
      plan {
        id
      }
      show
      current
    }
  }
GRAPHQL

RSpec.describe 'QueryPlans', type: :request do
  context 'when no site id is given' do
    it 'returns the plans' do
      response = graphql_request(plan_query, {}, nil)

      expect(response['data']['plans']).to eq(
        [
          {
            'id' => 'free',
            'name' => 'Free',
            'plan' => {
              'id' => '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f'
            },
            'show' => true,
            'current' => false
          },
          {
            'id' => 'starter',
            'name' => 'Starter',
            'plan' => {
              'id' => 'b5be7346-b896-4e4f-9598-e206efca98a6'
            },
            'show' => true,
            'current' => false
          },
          {
            'id' => 'light',
            'name' => 'Light',
            'plan' => {
              'id' => '094f6148-22d6-4201-9c5e-20bffb68cc48'
            },
            'show' => false,
            'current' => false
          },
          {
            'id' => 'plus',
            'name' => 'Plus',
            'plan' => {
              'id' => 'f20c93ec-172f-46c6-914e-6a00dff3ae5f'
            },
            'show' => false,
            'current' => false
          },
          {
            'id' => 'business',
            'name' => 'Business',
            'plan' => {
              'id' => 'b2054935-4fdf-45d0-929b-853cfe8d4a1c'
            },
            'show' => true,
            'current' => false
          },
          {
            'id' => 'enterprise',
            'name' => 'Enterprise',
            'plan' => nil,
            'show' => true,
            'current' => false
          }
        ]
      )
    end
  end

  context 'when a site id given but the user is not a member' do
    let(:site) { create(:site) }
    let(:user) { create(:user) }

    it 'returns the plans' do
      variables = { site_id: site.id }
      response = graphql_request(plan_query, variables, user)

      expect(response['data']['plans']).to eq(
        [
          {
            'id' => 'free',
            'name' => 'Free',
            'plan' => {
              'id' => '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f'
            },
            'show' => true,
            'current' => false
          },
          {
            'id' => 'starter',
            'name' => 'Starter',
            'plan' => {
              'id' => 'b5be7346-b896-4e4f-9598-e206efca98a6'
            },
            'show' => true,
            'current' => false
          },
          {
            'id' => 'light',
            'name' => 'Light',
            'plan' => {
              'id' => '094f6148-22d6-4201-9c5e-20bffb68cc48'
            },
            'show' => false,
            'current' => false
          },
          {
            'id' => 'plus',
            'name' => 'Plus',
            'plan' => {
              'id' => 'f20c93ec-172f-46c6-914e-6a00dff3ae5f'
            },
            'show' => false,
            'current' => false
          },
          {
            'id' => 'business',
            'name' => 'Business',
            'plan' => {
              'id' => 'b2054935-4fdf-45d0-929b-853cfe8d4a1c'
            },
            'show' => true,
            'current' => false
          },
          {
            'id' => 'enterprise',
            'name' => 'Enterprise',
            'plan' => nil,
            'show' => true,
            'current' => false
          }
        ]
      )
    end
  end

  context 'when a site id given and the user is a member' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    it 'returns the plans' do
      variables = { site_id: site.id }
      response = graphql_request(plan_query, variables, user)

      expect(response['data']['plans']).to eq(
        [
          {
            'id' => 'free',
            'name' => 'Free',
            'plan' => {
              'id' => '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f'
            },
            'show' => true,
            'current' => true
          },
          {
            'id' => 'starter',
            'name' => 'Starter',
            'plan' => {
              'id' => 'b5be7346-b896-4e4f-9598-e206efca98a6'
            },
            'show' => true,
            'current' => false
          },
          {
            'id' => 'light',
            'name' => 'Light',
            'plan' => {
              'id' => '094f6148-22d6-4201-9c5e-20bffb68cc48'
            },
            'show' => false,
            'current' => false
          },
          {
            'id' => 'plus',
            'name' => 'Plus',
            'plan' => {
              'id' => 'f20c93ec-172f-46c6-914e-6a00dff3ae5f'
            },
            'show' => false,
            'current' => false
          },
          {
            'id' => 'business',
            'name' => 'Business',
            'plan' => {
              'id' => 'b2054935-4fdf-45d0-929b-853cfe8d4a1c'
            },
            'show' => true,
            'current' => false
          },
          {
            'id' => 'enterprise',
            'name' => 'Enterprise',
            'plan' => nil,
            'show' => true,
            'current' => false
          }
        ]
      )
    end
  end
end
