# frozen_string_literal: true

require 'rails_helper'

site_visitors_highlights_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      visitorsHighlights(fromDate: $from_date, toDate: $to_date) {
        active {
          id
        }
        newest {
          id
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Visitors::Highlights, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user) }

  subject do
    variables = { 
      site_id: site.id, 
      from_date: '2022-10-24',
      to_date: '2022-10-30'
    }
    graphql_request(site_visitors_highlights_query, variables, user)
  end

  context 'when there are no visitors' do
    it 'returns no results' do
      expect(subject['data']['site']['visitorsHighlights']).to eq(
        'active' => [],
        'newest' => []
      )
    end
  end

  context 'when there are some visitors' do
    let!(:active_visitor_1) { create(:visitor, site_id: site.id, created_at: Time.new(2022, 10, 21)) }
    let!(:active_visitor_2) { create(:visitor, site_id: site.id, created_at: Time.new(2022, 10, 21)) }
    let!(:active_visitor_3) { create(:visitor, site_id: site.id, created_at: Time.new(2022, 10, 21)) }
    let!(:active_visitor_4) { create(:visitor, site_id: site.id, created_at: Time.new(2022, 10, 21)) }
    let!(:active_visitor_5) { create(:visitor, site_id: site.id, created_at: Time.new(2022, 10, 21)) }

    let!(:newest_visitor_1) { create(:visitor, site_id: site.id, created_at: Time.new(2022, 10, 30)) }
    let!(:newest_visitor_2) { create(:visitor, site_id: site.id, created_at: Time.new(2022, 10, 29)) }
    let!(:newest_visitor_3) { create(:visitor, site_id: site.id, created_at: Time.new(2022, 10, 28)) }
    let!(:newest_visitor_4) { create(:visitor, site_id: site.id, created_at: Time.new(2022, 10, 27)) }
    let!(:newest_visitor_5) { create(:visitor, site_id: site.id, created_at: Time.new(2022, 10, 26)) }

    before do
      create(:recording, visitor: active_visitor_1, site:)
      create(:recording, visitor: active_visitor_1, site:)
      create(:recording, visitor: active_visitor_1, site:)
      create(:recording, visitor: active_visitor_1, site:)
      create(:recording, visitor: active_visitor_1, site:)
      create(:recording, visitor: active_visitor_1, site:)
      create(:recording, visitor: active_visitor_2, site:)
      create(:recording, visitor: active_visitor_2, site:)
      create(:recording, visitor: active_visitor_2, site:)
      create(:recording, visitor: active_visitor_2, site:)
      create(:recording, visitor: active_visitor_3, site:)
      create(:recording, visitor: active_visitor_3, site:)
      create(:recording, visitor: active_visitor_3, site:)
      create(:recording, visitor: active_visitor_4, site:)
      create(:recording, visitor: active_visitor_4, site:)
      create(:recording, visitor: active_visitor_5, site:)
    end

    it 'returns the results' do
      expect(subject['data']['site']['visitorsHighlights']).to eq(
        'active' => [
          {
            'id' => active_visitor_1.id.to_s
          },
          {
            'id' => active_visitor_2.id.to_s
          },
          {
            'id' => active_visitor_3.id.to_s
          },
          {
            'id' => active_visitor_4.id.to_s
          },
          {
            'id' => active_visitor_5.id.to_s
          }         
        ],
        'newest' => [
          {
            'id' => newest_visitor_1.id.to_s
          },
          {
            'id' => newest_visitor_2.id.to_s
          },
          {
            'id' => newest_visitor_3.id.to_s
          },
          {
            'id' => newest_visitor_4.id.to_s
          },
          {
            'id' => newest_visitor_5.id.to_s
          }
        ]
      )
    end
  end
end
