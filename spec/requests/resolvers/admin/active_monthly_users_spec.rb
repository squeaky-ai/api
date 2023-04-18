# frozen_string_literal: true

require 'rails_helper'

active_monthly_users_admin_query = <<-GRAPHQL
  query {
    admin {
      activeMonthlyUsers
    }
  }
GRAPHQL

RSpec.describe Resolvers::Admin::ActiveMonthlyUsers, type: :request do
  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      response = graphql_request(active_monthly_users_admin_query, {}, user)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser but there are no active monthly users' do
    let(:user) { create(:user, superuser: true) }

    it 'returns 0' do
      response = graphql_request(active_monthly_users_admin_query, {}, user)

      expect(response['data']['admin']['activeMonthlyUsers']).to eq 0
    end
  end

  context 'when the user is a superuser and there are active monthly users' do
    let(:user) { create(:user, superuser: true) }

    before do
      now = Time.now

      create(:user, last_activity_at: now - 5.days)
      create(:user, last_activity_at: now - 15.days)
      create(:user, last_activity_at: now - 25.days)
      create(:user, last_activity_at: now - 35.days)
    end

    it 'returns the amount of active users' do
      response = graphql_request(active_monthly_users_admin_query, {}, user)

      expect(response['data']['admin']['activeMonthlyUsers']).to eq 3
    end
  end
end
