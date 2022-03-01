# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

active_users_admin_query = <<-GRAPHQL
  query {
    activeUsersAdmin
  }
GRAPHQL

RSpec.describe 'QueryActiveUsersAdminQuery', type: :request do
  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      response = graphql_request(active_users_admin_query, {}, user)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser but there are no active users' do
    let(:user) { create(:user, superuser: true) }

    before do
      Redis.current.keys('active_user_count:*').each { |key| Redis.current.del(key) }
    end

    it 'returns all the sites' do
      response = graphql_request(active_users_admin_query, {}, user)

      expect(response['data']['activeUsersAdmin']).to eq 0
    end
  end

  context 'when the user is a superuser and there are active users' do
    let(:user) { create(:user, superuser: true) }

    before do
      Redis.current.set("active_user_count:#{SecureRandom.uuid}", '5')
      Redis.current.set("active_user_count:#{SecureRandom.uuid}", '1')
      Redis.current.set("active_user_count:#{SecureRandom.uuid}", '0')
    end

    it 'returns all the sites' do
      response = graphql_request(active_users_admin_query, {}, user)

      expect(response['data']['activeUsersAdmin']).to eq 6
    end
  end
end
