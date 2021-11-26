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
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

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
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:93.0) Gecko/20100101 Firefox/93.0' }, site: site, visitor: create_visitor)
      create_recording({ useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15' }, site: site, visitor: create_visitor)
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
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:93.0) Gecko/20100101 Firefox/93.0' }, site: site, visitor: create_visitor)
      create_recording({ useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:93.0) Gecko/20100101 Firefox/93.0' }, site: site, visitor: create_visitor)
      create_recording({ useragent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15' }, site: site, visitor: create_visitor)
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
