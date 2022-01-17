# frozen_string_literal: true

require 'rails_helper'

site_country_codes_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      countryCodes
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::Browsers, type: :request do
  context 'when there are no country codes' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_country_codes_query, variables, user)
    end

    it 'returns no country codes' do
      response = subject['data']['site']['countryCodes']
      expect(response).to eq []
    end
  end

  context 'when there are some country codes' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, country_code: 'GB', site: site)
      create(:recording, country_code: 'SE', site: site)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_country_codes_query, variables, user)
    end

    it 'returns the country codes' do
      response = subject['data']['site']['countryCodes']
      expect(response).to eq ['GB', 'SE']
    end
  end

  context 'when there are some duplicate country codes' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, country_code: 'GB', site: site)
      create(:recording, country_code: 'SE', site: site)
      create(:recording, country_code: 'GB', site: site)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_country_codes_query, variables, user)
    end

    it 'returns them deduped' do
      response = subject['data']['site']['countryCodes']
      expect(response).to eq ['GB', 'SE']
    end
  end
end
