# frozen_string_literal: true

require 'rails_helper'

site_session_settings_query = <<-GRAPHQL
  query($site_id: String!) {
    siteSessionSettings(siteId: $site_id) {
      cssSelectorBlacklist
      anonymiseFormInputs
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::SiteSessionSettings, type: :request do
  context 'when the site does not exist' do
    subject do
      graphql_request(site_session_settings_query, { site_id: SecureRandom.uuid }, nil)
    end

    it 'returns nil' do
      expect(subject['data']['siteSessionSettings']).to eq nil
    end
  end

  context 'when the site has no selectors' do
    let(:site) { create(:site) }

    subject do
      graphql_request(site_session_settings_query, { site_id: site.uuid }, nil)
    end

    it 'returns an empty array' do
      expect(subject['data']['siteSessionSettings']['cssSelectorBlacklist']).to eq []
    end
  end

  context 'when the site has selectors' do
    let(:site) { create(:site, css_selector_blacklist: ['foo > bar', 'bar#baz']) }

    subject do
      graphql_request(site_session_settings_query, { site_id: site.uuid }, nil)
    end

    it 'returns the selectors' do
      expect(subject['data']['siteSessionSettings']['cssSelectorBlacklist']).to eq ['foo > bar', 'bar#baz']
    end
  end

  context 'when the site has forms anonymised' do
    let(:site) { create(:site, anonymise_form_inputs: true) }

    subject do
      graphql_request(site_session_settings_query, { site_id: site.uuid }, nil)
    end

    it 'returns the selectors' do
      expect(subject['data']['siteSessionSettings']['anonymiseFormInputs']).to eq true
    end
  end

  context 'when the site does not have forms anonymised' do
    let(:site) { create(:site, anonymise_form_inputs: false) }

    subject do
      graphql_request(site_session_settings_query, { site_id: site.uuid }, nil)
    end

    it 'returns the selectors' do
      expect(subject['data']['siteSessionSettings']['anonymiseFormInputs']).to eq false
    end
  end
end
