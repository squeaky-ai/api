# frozen_string_literal: true

require 'rails_helper'

site_superuser_access_enabled_mutation = <<-GRAPHQL
  mutation($input: SitesSuperuserAccessUpdateInput!) {
    superuserAccessUpdate(input: $input) {
      superuserAccessEnabled
    }
  }
GRAPHQL

RSpec.describe Mutations::Sites::SuperuserAccessUpdate, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user) }

  subject do
    variables = { 
      input: {
        siteId: site.id, 
        enabled: true
      }
    }

    graphql_request(site_superuser_access_enabled_mutation, variables, user)
  end

  it 'updates the value' do
    expect { subject }.to change { site.reload.superuser_access_enabled }.from(false).to(true)
  end

  it 'returns the updated value' do
    response = subject['data']['superuserAccessUpdate']['superuserAccessEnabled']
    expect(response).to eq true
  end
end
