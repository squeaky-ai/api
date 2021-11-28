# frozen_string_literal: true

require 'rails_helper'

site_languages_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      languages
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::Languages, type: :request do
  context 'when there are no languages' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_languages_query, variables, user)
    end

    it 'returns no languages' do
      response = subject['data']['site']['languages']
      expect(response).to eq []
    end
  end

  context 'when there are some languages' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ locale: 'en-GB' }, site: site, visitor: create_visitor)
      create_recording({ locale: 'sv-SE' }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_languages_query, variables, user)
    end

    it 'returns the languages' do
      response = subject['data']['site']['languages']
      expect(response).to eq ['English (GB)', 'Swedish (SE)']
    end
  end

  context 'when there are some duplicate languages' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ locale: 'en-GB' }, site: site, visitor: create_visitor)
      create_recording({ locale: 'en-GB' }, site: site, visitor: create_visitor)
      create_recording({ locale: 'sv-SE' }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_languages_query, variables, user)
    end

    it 'returns them deduped' do
      response = subject['data']['site']['languages']
      expect(response).to eq ['English (GB)', 'Swedish (SE)']
    end
  end
end