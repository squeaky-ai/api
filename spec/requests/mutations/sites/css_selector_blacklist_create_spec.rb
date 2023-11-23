# frozen_string_literal: true

require 'rails_helper'

site_css_selector_blacklist_create_mutation = <<-GRAPHQL
  mutation($input: SitesCssSelectorBlacklistCreateInput!) {
    cssSelectorBlacklistCreate(input: $input) {
      cssSelectorBlacklist
    }
  }
GRAPHQL

RSpec.describe Mutations::Sites::CssSelectorBlacklistCreate, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user) }

  subject do
    variables = {
      input: {
        siteId: site.id,
        selector: 'foo'
      }
    }

    graphql_request(site_css_selector_blacklist_create_mutation, variables, user)
  end

  it 'updates the value' do
    expect { subject }.to change { site.reload.css_selector_blacklist }.from([]).to(['foo'])
  end

  it 'returns the updated value' do
    response = subject['data']['cssSelectorBlacklistCreate']['cssSelectorBlacklist']
    expect(response).to eq ['foo']
  end

  context 'when there are duplicates' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user, css_selector_blacklist: %w[foo bar]) }

    subject do
      variables = {
        input: {
          siteId: site.id,
          selector: 'foo'
        }
      }

      graphql_request(site_css_selector_blacklist_create_mutation, variables, user)
    end

    it 'dedupes them' do
      subject
      expect(site.reload.css_selector_blacklist).to eq(%w[foo bar])
    end
  end
end
