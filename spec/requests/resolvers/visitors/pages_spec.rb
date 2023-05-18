# frozen_string_literal: true

require 'rails_helper'

visitor_pages_query = <<-GRAPHQL
  query($site_id: ID!, $visitor_id: ID!, $page: Int, $sort: VisitorsPagesSort) {
    site(siteId: $site_id) {
      visitor(visitorId: $visitor_id) {
        pages(page: $page, size: 10, sort: $sort) {
          items {
            pageView
            pageViewCount
            averageTimeOnPage
          }
          pagination {
            pageSize
            total
            sort
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Visitors::Pages, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, visitor_id: 1 }
      graphql_request(visitor_pages_query, variables, user)
    end

    it 'returns nil for the visitor' do
      response = subject['data']['site']['visitor']
      expect(response).to be nil
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:visitor) { create(:visitor, site_id: site.id) }

    let(:recording_1) { create(:recording, site:) }
    let(:recording_2) { create(:recording, site:) }
    let(:recording_3) { create(:recording, site:) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_1.id,
          visitor_id: visitor.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_2.id,
          visitor_id: visitor.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording_3.id,
          visitor_id: visitor.id
        }
      ]
    end

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          activity_duration: 1000,
          recording_id: recording_1.id,
          visitor_id: visitor.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          activity_duration: 2000,
          recording_id: recording_2.id,
          visitor_id: visitor.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test',
          activity_duration: 1000,
          recording_id: recording_2.id,
          visitor_id: visitor.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/contact',
          activity_duration: 2300,
          recording_id: recording_3.id,
          visitor_id: visitor.id
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
      variables = { site_id: site.id, visitor_id: visitor.id }
      graphql_request(visitor_pages_query, variables, user)
    end

    it 'returns the pages for this visitor' do
      response = subject['data']['site']['visitor']['pages']
      expect(response['items'].size).to eq 3
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['visitor']['pages']
      expect(response['pagination']).to eq(
        'pageSize' => 10,
        'sort' => 'views_count__desc',
        'total' => 3
      )
    end
  end
end
