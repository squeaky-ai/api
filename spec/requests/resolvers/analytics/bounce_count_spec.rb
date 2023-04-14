# typed: false
# frozen_string_literal: true

require 'rails_helper'

analytics_bounce_count_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        bounceCounts {
          groupType
          groupRange
          items {
            dateKey
            viewCount
            bounceRateCount
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::BounceCount, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user) }

  subject do
    variables = { 
      site_id: site.id,
      from_date: '2022-10-23',
      to_date: '2022-10-30' 
    }
    graphql_request(analytics_bounce_count_query, variables, user)
  end

  context 'when there are no pages' do
    it 'returns an empty array' do
      response = subject['data']['site']['analytics']

      expect(response['bounceCounts']).to eq(
        'groupType' => 'daily',
        'groupRange' => 7,
        'items' => []
      )
    end
  end

  context 'when there are pages' do
    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          entered_at: 1667028000074, 
          exited_at: 1667028026074, 
          bounced_on: true
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          entered_at: 1667028001074, 
          exited_at: 1667028026074, 
          bounced_on: false
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          entered_at: 1667028002074, 
          exited_at: 1667028026074, 
          bounced_on: false
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          entered_at: 1667028012074, 
          exited_at: 1667028026074, 
          bounced_on: true
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          entered_at: 1667028014074, 
          exited_at: 1667028026074, 
          bounced_on: false
        }
      ]
    end

    before do
      ClickHouse::PageEvent.insert do |buffer|
        pages.each { |page| buffer << page }
      end
    end

    it 'returns the results' do
      response = subject['data']['site']['analytics']

      expect(response['bounceCounts']).to eq(
        'groupType' => 'daily',
        'groupRange' => 7,
        'items' => [
          {
            'dateKey' => '302',
            'viewCount' => 5,
            'bounceRateCount' => 2,
          }
        ]
      )
    end
  end
end
