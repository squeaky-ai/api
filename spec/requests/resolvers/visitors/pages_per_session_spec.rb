# frozen_string_literal: true

require 'rails_helper'

visitors_pages_per_session_query = <<-GRAPHQL
  query($site_id: ID!, $visitor_id: ID!) {
    site(siteId: $site_id) {
      visitor(visitorId: $visitor_id) {
        pagesPerSession
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Visitors::PagesPerSession, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, visitor_id: 1 }
      graphql_request(visitors_pages_per_session_query, variables, user)
    end

    it 'returns nil for the visitor' do
      response = subject['data']['site']['visitor']
      expect(response).to be nil
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:visitor) { create(:visitor) }

    before do
      create(:recording, site: site, page_urls: ['/'], visitor: visitor)
      create(:recording, site: site, page_urls: ['/', '/test'], visitor: visitor)
      create(:recording, site: site, page_urls: ['/contact'])
    end

    subject do
      variables = { site_id: site.id, visitor_id: visitor.id }
      graphql_request(visitors_pages_per_session_query, variables, user)
    end

    it 'returns the number of pages per session for this visitor' do
      response = subject['data']['site']['visitor']
      expect(response['pagesPerSession']).to eq 1.33
    end
  end
end
