# typed: false
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
    let(:recording_1) { create(:recording, site:) }
    let(:recording_2) { create(:recording, site:) }
    let(:recording_3) { create(:recording, site:) }
    let(:visitor_1) { create(:visitor, site_id: site.id) }
    let(:visitor_2) { create(:visitor, site_id: site.id) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_1.id,
          visitor_id: visitor_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_2.id,
          visitor_id: visitor_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_3.id,
          visitor_id: visitor_2.id
        }
      ]
    end

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          recording_id: recording_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          recording_id: recording_2.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test',
          recording_id: recording_2.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/contact',
          recording_id: recording_3.id
        }
      ]
    end

    before do
      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end

      ClickHouse::PageEvent.insert do |buffer|
        pages.each { |page| buffer << page }
      end
    end

    subject do
      variables = { site_id: site.id, visitor_id: visitor_1.id }
      graphql_request(visitors_pages_per_session_query, variables, user)
    end

    it 'returns the number of pages per session for this visitor' do
      response = subject['data']['site']['visitor']
      expect(response['pagesPerSession']).to eq 1.5
    end
  end
end
