# frozen_string_literal: true

require 'rails_helper'

css_selector_blacklist_query = <<-GRAPHQL
  query($site_id: String!) {
    cssSelectorBlacklist(siteId: $site_id)
  }
GRAPHQL

RSpec.describe 'CssSelectorBlacklistQuery', type: :request do
  context 'when the site does not exist' do
    subject do
      graphql_request(css_selector_blacklist_query, { site_id: SecureRandom.uuid }, nil)
    end

    it 'returns an empty array' do
      expect(subject['data']['cssSelectorBlacklist']).to eq []
    end
  end

  context 'when the site has no selectors' do
    let(:site) { create(:site) }

    subject do
      graphql_request(css_selector_blacklist_query, { site_id: SecureRandom.uuid }, nil)
    end

    it 'returns an empty array' do
      expect(subject['data']['cssSelectorBlacklist']).to eq []
    end
  end

  context 'when the site has selectors' do
    let(:site) { create(:site, css_selector_blacklist: ['foo > bar', 'bar#baz']) }

    subject do
      graphql_request(css_selector_blacklist_query, { site_id: site.uuid }, nil)
    end

    it 'returns the selectors' do
      expect(subject['data']['cssSelectorBlacklist']).to eq ['foo > bar', 'bar#baz']
    end
  end
end
