# frozen_string_literal: true

require 'rails_helper'

site_magic_erasure_enabled_mutation = <<-GRAPHQL
  mutation($input: SitesMagicErasureUpdateInput!) {
    magicErasureUpdate(input: $input) {
      magicErasureEnabled
    }
  }
GRAPHQL

RSpec.describe Mutations::Sites::MagicErasureUpdate, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user) }

  subject do
    variables = {
      input: {
        siteId: site.id,
        enabled: true
      }
    }

    graphql_request(site_magic_erasure_enabled_mutation, variables, user)
  end

  it 'updates the value' do
    expect { subject }.to change { site.reload.magic_erasure_enabled }.from(false).to(true)
  end

  it 'returns the updated value' do
    response = subject['data']['magicErasureUpdate']['magicErasureEnabled']
    expect(response).to eq true
  end
end
