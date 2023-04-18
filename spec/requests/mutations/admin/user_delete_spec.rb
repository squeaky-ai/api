# frozen_string_literal: true

require 'rails_helper'

admin_user_delete_mutation = <<-GRAPHQL
  mutation($input: AdminUserDeleteInput!) {
    adminUserDelete(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::UserDelete, type: :request do
  context 'when the user does not own any sites' do
    let(:user) { create(:user, superuser: true) }
    let(:user_to_delete) { create(:user) }

    subject do
      variables = {
        input: {
          id: user_to_delete.id
        }
      }
  
      graphql_request(admin_user_delete_mutation, variables, user)
    end

    it 'returns nil' do
      expect(subject['data']['adminUserDelete']).to be_nil
    end
  
    it 'deletes the record' do
      subject
      expect { user_to_delete.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when the user is the owner of some sites' do
    let(:user) { create(:user, superuser: true) }
    let(:user_to_delete) { create(:user) }

    subject do
      variables = {
        input: {
          id: user_to_delete.id
        }
      }
  
      graphql_request(admin_user_delete_mutation, variables, user)
    end

    before do
      create(:site_with_team, owner: user_to_delete)
      create(:site_with_team, owner: user_to_delete)
    end

    it 'destroys all of those sites' do
      expect { subject }.to change { user_to_delete.sites.size }.from(2).to(0)
    end
  end

  context 'when the user is a member of a site' do
    let(:user) { create(:user, superuser: true) }
    let(:site) { create(:site_with_team) }
    let(:user_to_delete) { create(:user) }

    before { create(:team, user: user_to_delete, site: site, role: Team::MEMBER) }

    subject do
      variables = {
        input: {
          id: user_to_delete.id
        }
      }
  
      graphql_request(admin_user_delete_mutation, variables, user)
    end

    it 'destroys the team record' do
      expect { subject }.to change { site.team.size }.from(2).to(1)
    end

    it 'does not destroy the site' do
      expect { subject }.not_to change { Site.exists?(site.id) }
    end
  end
end
