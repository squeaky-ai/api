# frozen_string_literal: true

require 'rails_helper'

active_visitors_admin_query = <<-GRAPHQL
  query {
    admin {
      activeVisitors {
        siteId
        count
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Admin::ActiveVisitors, type: :request do
  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      response = graphql_request(active_visitors_admin_query, {}, user)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser but there are no active visitors' do
    let(:user) { create(:user, superuser: true) }

    before { Cache.redis.del('active_user_count') }

    it 'returns all the sites' do
      response = graphql_request(active_visitors_admin_query, {}, user)

      expect(response['data']['admin']['activeVisitors']).to eq []
    end
  end

  context 'when the user is a superuser and there are active visitors' do
    let(:user) { create(:user, superuser: true) }
    let(:site_1_id) { SecureRandom.uuid }
    let(:site_2_id) { SecureRandom.uuid }
    let(:site_3_id) { SecureRandom.uuid }

    before do
      Cache.redis.del('active_user_count')

      Cache.redis.zincrby('active_user_count', 1, site_1_id)
      Cache.redis.zincrby('active_user_count', 5, site_2_id)
      Cache.redis.zincrby('active_user_count', 3, site_3_id)
    end

    it 'returns all the sites' do
      response = graphql_request(active_visitors_admin_query, {}, user)

      expect(response['data']['admin']['activeVisitors']).to match_array(
        [
          {
            'siteId' => site_1_id,
            'count' => 1
          },
          {
            'siteId' => site_2_id,
            'count' => 5
          },
          {
            'siteId' => site_3_id,
            'count' => 3
          }
        ]
      )
    end
  end
end
