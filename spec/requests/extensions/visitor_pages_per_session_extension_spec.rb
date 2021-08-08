# frozen_string_literal: true

require 'rails_helper'

visitors_pages_per_session_query = <<-GRAPHQL
  query($site_id: ID!, $viewer_id: ID!) {
    site(siteId: $site_id) {
      visitor(viewerId: $viewer_id) {
        pagesPerSession
      }
    }
  }
GRAPHQL

RSpec.describe Types::VisitorPagesPerSessionExtension, type: :request do
  context 'when there are no recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:viewer_id) { 'aaaaaaa' }

    subject do
      variables = { site_id: site.id, viewer_id: viewer_id }
      graphql_request(visitors_pages_per_session_query, variables, user)
    end

    it 'returns nil for the visitor' do
      response = subject['data']['site']['visitor']
      expect(response).to be nil
    end
  end

  context 'when there are some recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:viewer_id) { 'aaaaaaa' }

    before do
      create_recording({ deleted: true, viewer_id: viewer_id, page_views: ['/'] }, site: site)
      create_recording({ deleted: true, viewer_id: viewer_id, page_views: ['/', '/test'] }, site: site)
      create_recording({ deleted: true, viewer_id: 'bbbbbbb', page_views: ['/contact'] }, site: site)
    end

    subject do
      variables = { site_id: site.id, viewer_id: viewer_id }
      graphql_request(visitors_pages_per_session_query, variables, user)
    end

    it 'returns the number of pages per session for this viewer' do
      response = subject['data']['site']['visitor']
      expect(response['pagesPerSession']).to eq 1.5
    end
  end
end
