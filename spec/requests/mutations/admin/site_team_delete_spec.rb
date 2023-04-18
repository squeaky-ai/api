# frozen_string_literal: true

require 'rails_helper'

admin_site_team_delete_mutation = <<-GRAPHQL
  mutation($input: AdminSiteTeamDeleteInput!) {
    adminSiteTeamDelete(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::SiteTeamDelete, type: :request do
  context 'when the user is the owner' do
    let(:user) { create(:user, superuser: true) }
    let(:user_to_delete) { create(:user) }
    let!(:site) { create(:site_with_team, owner: user_to_delete) }

    subject do
      variables = {
        input: {
          id: site.owner.id
        }
      }
  
      graphql_request(admin_site_team_delete_mutation, variables, user)
    end

    it 'returns nil' do
      expect(subject['data']['adminSiteTeamDelete']).to be_nil
    end
  
    it 'does not delete the record' do
      expect { subject }.not_to change { site.team.size }
    end
  end

  context 'when the usder is not the owner' do
    let(:user) { create(:user, superuser: true) }
    let(:user_to_delete) { create(:user) }
    let!(:site) { create(:site_with_team) }
    let!(:team) { create(:team, site:, user:, role: Team::ADMIN) }

    subject do
      variables = {
        input: {
          id: team.id
        }
      }
  
      graphql_request(admin_site_team_delete_mutation, variables, user)
    end

    it 'returns nil' do
      expect(subject['data']['adminSiteTeamDelete']).to be_nil
    end
  
    it 'deletes delete the record' do
      subject
      expect { team.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'removes them from the team' do
      expect { subject }.to change { site.team.size }.from(2).to(1)
    end
  end
end
