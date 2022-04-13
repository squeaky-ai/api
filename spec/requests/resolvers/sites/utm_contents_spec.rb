# frozen_string_literal: true

require 'rails_helper'

site_utm_contents_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      utmContents
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::UtmContents, type: :request do
  context 'when there are no contents' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_utm_contents_query, variables, user)
    end

    it 'returns no contents' do
      response = subject['data']['site']['utmContents']
      expect(response).to eq []
    end
  end

  context 'when there are some contents' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, utm_content: 'content_1', site: site)
      create(:recording, utm_content: 'content_2', site: site)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_utm_contents_query, variables, user)
    end

    it 'returns the contents' do
      response = subject['data']['site']['utmContents']
      expect(response).to eq ['content_1', 'content_2']
    end
  end

  context 'when there are some duplicate contents' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:recording, utm_content: 'content_1', site: site)
      create(:recording, utm_content: 'content_2', site: site)
      create(:recording, utm_content: 'content_1', site: site)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_utm_contents_query, variables, user)
    end

    it 'returns them deduped' do
      response = subject['data']['site']['utmContents']
      expect(response).to eq ['content_1', 'content_2']
    end
  end
end
