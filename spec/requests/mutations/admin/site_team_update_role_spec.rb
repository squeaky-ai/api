# typed: false
# frozen_string_literal: true

require 'rails_helper'

admin_site_update_role_mutation = <<-GRAPHQL
  mutation($input: AdminSiteTeamUpdateRoleInput!) {
    adminSiteTeamUpdateRole(input: $input) {
      id
      role
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::SiteTeamUpdateRole, type: :request do
  let(:user) { create(:user, superuser: true) }
  let(:user_to_delete) { create(:user) }
  let!(:site) { create(:site_with_team, owner: user_to_delete) }

  subject do
    variables = {
      input: {
        id: site.owner.id,
        role: Team::READ_ONLY
      }
    }

    graphql_request(admin_site_update_role_mutation, variables, user)
  end

  it 'returns the updated team' do
    expect(subject['data']['adminSiteTeamUpdateRole']['role']).to eq(Team::READ_ONLY)
  end

  it 'updates the record' do
    expect { subject }.to change { site.reload.team.first.role }.from(Team::OWNER).to(Team::READ_ONLY)
  end
end
