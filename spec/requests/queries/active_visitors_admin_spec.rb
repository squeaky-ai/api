# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

active_visitors_admin_query = <<-GRAPHQL
  query {
    activeVisitorsAdmin {
      siteId
      count
    }
  }
GRAPHQL

RSpec.describe 'QueryActiveVisitorsAdminQuery', type: :request do
  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      response = graphql_request(active_visitors_admin_query, {}, user)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser but there are no active visitors' do
    let(:user) { create(:user, superuser: true) }

    before { Redis.current.del('active_user_count') }

    it 'returns all the sites' do
      response = graphql_request(active_visitors_admin_query, {}, user)

      expect(response['data']['activeVisitorsAdmin']).to eq []
    end
  end

  context 'when the user is a superuser and there are active visitors' do
    let(:user) { create(:user, superuser: true) }
    let(:site_1_id) { SecureRandom.uuid }
    let(:site_2_id) { SecureRandom.uuid }
    let(:site_3_id) { SecureRandom.uuid }

    before do
      Redis.current.del('active_user_count')

      Redis.current.zincrby('active_user_count', 1, site_1_id)
      Redis.current.zincrby('active_user_count', 5, site_2_id)
      Redis.current.zincrby('active_user_count', 3, site_3_id)
    end

    it 'returns all the sites' do
      response = graphql_request(active_visitors_admin_query, {}, user)

      expect(response['data']['activeVisitorsAdmin']).to match_array(
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
