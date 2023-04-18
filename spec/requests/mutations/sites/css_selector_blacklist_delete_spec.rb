# typed: false
# frozen_string_literal: true

require 'rails_helper'

site_css_selector_blacklist_delete_mutation = <<-GRAPHQL
  mutation($input: SitesCssSelectorBlacklistDeleteInput!) {
    cssSelectorBlacklistDelete(input: $input) {
      cssSelectorBlacklist
    }
  }
GRAPHQL

RSpec.describe Mutations::Sites::CssSelectorBlacklistDelete, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user, css_selector_blacklist: ['foo']) }

  subject do
    variables = { 
      input: {
        siteId: site.id, 
        selector: 'foo'
      }
    }

    graphql_request(site_css_selector_blacklist_delete_mutation, variables, user)
  end

  it 'updates the value' do
    expect { subject }.to change { site.reload.css_selector_blacklist }.from(['foo']).to([])
  end

  it 'returns the updated value' do
    response = subject['data']['cssSelectorBlacklistDelete']['cssSelectorBlacklist']
    expect(response).to eq []
  end

  context 'when the selector does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user, css_selector_blacklist: []) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          selector: 'foo'
        }
      }
  
      graphql_request(site_css_selector_blacklist_delete_mutation, variables, user)
    end

    it 'does not complain' do
      subject
      expect(site.reload.css_selector_blacklist).to eq([])
    end
  end
end
