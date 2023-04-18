# frozen_string_literal: true

require 'rails_helper'

admin_ingest_update_mutation = <<-GRAPHQL
  mutation($input: AdminSiteIngestUpdateInput!) {
    adminSiteIngestUpdate(input: $input) {
      ingestEnabled
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::SiteIngestUpdate, type: :request do
  let(:user) { create(:user, superuser: true) }
  let(:site) { create(:site) }

  subject do
    variables = {
      input: {
        siteId: site.id,
        enabled: false
      }
    }

    graphql_request(admin_ingest_update_mutation, variables, user)
  end

  it 'returns the updated site' do
    response = subject['data']['adminSiteIngestUpdate']
    expect(response['ingestEnabled']).to eq(false)
  end
end
