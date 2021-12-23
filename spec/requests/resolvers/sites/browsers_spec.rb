# frozen_string_literal: true

require 'rails_helper'

site_browsers_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      browsers
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::Browsers, type: :request do
  context 'when there are no browsers' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_browsers_query, variables, user)
    end

    it 'returns no browsers' do
      response = subject['data']['site']['browsers']
      expect(response).to eq []
    end
  end

  context 'when there are some browsers' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, browser: 'Firefox', site: site)
      create(:recording, browser: 'Safari', site: site)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_browsers_query, variables, user)
    end

    it 'returns the browsers' do
      response = subject['data']['site']['browsers']
      expect(response).to eq ['Firefox', 'Safari']
    end
  end

  context 'when there are some duplicate browsers' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, browser: 'Firefox', site: site)
      create(:recording, browser: 'Safari', site: site)
      create(:recording, browser: 'Firefox', site: site)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_browsers_query, variables, user)
    end

    it 'returns them deduped' do
      response = subject['data']['site']['browsers']
      expect(response).to eq ['Firefox', 'Safari']
    end
  end
end
