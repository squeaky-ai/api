# frozen_string_literal: true

require 'rails_helper'

site_css_selector_blacklist_update_mutation = <<-GRAPHQL
  mutation($input: SitesCssSelectorBlacklistUpdateInput!) {
    cssSelectorBlacklistUpdate(input: $input) {
      cssSelectorBlacklist
    }
  }
GRAPHQL

RSpec.describe Mutations::Sites::CssSelectorBlacklistUpdate, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user) }

  subject do
    variables = { 
      input: {
        siteId: site.id, 
        selectors: ['foo', 'bar', 'baz']
      }
    }

    graphql_request(site_css_selector_blacklist_update_mutation, variables, user)
  end

  it 'updates the value' do
    expect { subject }.to change { site.reload.css_selector_blacklist }.from([]).to(['foo', 'bar', 'baz'])
  end

  it 'returns the updated value' do
    response = subject['data']['cssSelectorBlacklistUpdate']['cssSelectorBlacklist']
    expect(response).to eq ['foo', 'bar', 'baz']
  end

  context 'when there are duplicates' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user, css_selector_blacklist: ['foo', 'bar']) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          selectors: ['foo', 'foo', 'bar', 'baz']
        }
      }
  
      graphql_request(site_css_selector_blacklist_update_mutation, variables, user)
    end

    it 'dedupes them' do
      subject
      expect(site.reload.css_selector_blacklist).to eq(['foo', 'bar', 'baz'])
    end
  end
end
