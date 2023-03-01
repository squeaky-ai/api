# frozen_string_literal: true

require 'rails_helper'

admin_site_bundles_create_mutation = <<-GRAPHQL
  mutation($input: AdminSiteBundlesCreateInput!) {
    adminSiteBundlesCreate(input: $input) {
      id
      sites {
        id
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::SiteBundlesCreate, type: :request do
  let(:user) { create(:user, superuser: true) }
  let(:site) { create(:site_with_team) }
  let(:site_bundle) { create(:site_bundle) }

  let(:new_site) { create(:site) }

  before do
    site.plan.update(plan_id: 'b2054935-4fdf-45d0-929b-853cfe8d4a1c')
    create(:site_bundles_site, site:, site_bundle:, primary: true)
  end

  subject do
    variables = {
      input: {
        siteId: new_site.id,
        bundleId: site_bundle.id
      }
    }

    graphql_request(admin_site_bundles_create_mutation, variables, user)
  end

  it 'returns the updated bundle data' do
    expect(subject['data']['adminSiteBundlesCreate']['sites']).to eq([
      {
        'id' => site.id.to_s
      },
      {
        'id' => new_site.id.to_s
      }
    ])
  end

  it 'creates the bundle database' do
    expect { subject }.to change { site_bundle.reload.sites.size }.by(1)
  end

  it 'inherits the primary sites plan' do
    expect { subject }.to change { new_site.reload.plan.plan_id }.from('05bdce28-3ac8-4c40-bd5a-48c039bd3c7f').to(site.plan.plan_id)
  end
end
