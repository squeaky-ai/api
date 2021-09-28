# frozen_string_literal: true

require 'rails_helper'

site_pages_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      pages
    }
  }
GRAPHQL

RSpec.describe Types::PagesExtension, type: :request do
  context 'when there are no pages' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_pages_query, variables, user)
    end

    it 'returns no pages' do
      response = subject['data']['site']['pages']
      expect(response).to eq []
    end
  end

  context 'when there are some pages' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ pages: [Page.new({ url: '/', entered_at: 0, exited_at: 0 })] }, site: site, visitor: create_visitor)
      create_recording({ pages: [Page.new({ url: '/test', entered_at: 0, exited_at: 0 })] }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_pages_query, variables, user)
    end

    it 'returns the pages' do
      response = subject['data']['site']['pages']
      expect(response).to eq ['/', '/test']
    end
  end

  context 'when there are some duplicate pages' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recording({ pages: [Page.new({ url: '/', entered_at: 0, exited_at: 0 })] }, site: site, visitor: create_visitor)
      create_recording({ pages: [Page.new({ url: '/', entered_at: 0, exited_at: 0 })] }, site: site, visitor: create_visitor)
      create_recording({ pages: [Page.new({ url: '/test', entered_at: 0, exited_at: 0 })] }, site: site, visitor: create_visitor)
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_pages_query, variables, user)
    end

    it 'returns them deduped' do
      response = subject['data']['site']['pages']
      expect(response).to eq ['/', '/test']
    end
  end
end
