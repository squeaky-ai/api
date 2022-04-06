# frozen_string_literal: true

require 'rails_helper'

roles_admin_query = <<-GRAPHQL
  query {
    admin {
      roles {
        owners
        admins
        members
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Admin::Roles, type: :request do
  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      response = graphql_request(roles_admin_query, {}, user)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'whjen the user is a superuser' do
    let(:user) { create(:user, superuser: true) }

    before do
      Team.destroy_all

      create(:team, role: 2)
      create(:team, role: 2)
      create(:team, role: 1)
      create(:team, role: 0)
      create(:team, role: 0)
      create(:team, role: 0)
    end

    it 'returns the counts' do
      response = graphql_request(roles_admin_query, {}, user)

      expect(response['data']['admin']['roles']).to eq(
        'owners' => 2,
        'admins' => 1,
        'members' => 3
      )
    end
  end
end
