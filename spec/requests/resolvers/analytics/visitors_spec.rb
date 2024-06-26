# frozen_string_literal: true

require 'rails_helper'

analytics_visitors_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        visitors {
          groupType
          groupRange
          items {
            dateKey
            allCount
            newCount
            existingCount
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::Visitors, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_visitors_query, variables, user)
    end

    it 'returns an empty array' do
      response = subject['data']['site']['analytics']

      expect(response['visitors']).to eq(
        'groupType' => 'daily',
        'groupRange' => 7,
        'items' => []
      )
    end
  end

  context 'when there are some visitors' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:visitor, created_at: Time.new(2021, 8, 6).utc, site_id: site.id, new: true)
      create(:visitor, created_at: Time.new(2021, 8, 7).utc, site_id: site.id, new: true)
      create(:visitor, created_at: Time.new(2021, 8, 8).utc, site_id: site.id, new: false)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_visitors_query, variables, user)
    end

    it 'returns the visitors' do
      response = subject['data']['site']['analytics']

      expect(response['visitors']['groupType']).to eq('daily')
      expect(response['visitors']['groupRange']).to eq(7)
      expect(response['visitors']['items']).to match([
        {
          'allCount' => 1,
          'dateKey' => '217',
          'existingCount' => 0,
          'newCount' => 1
        },
        {
          'allCount' => 1,
          'dateKey' => '218',
          'existingCount' => 0,
          'newCount' => 1
        },
        {
          'allCount' => 1,
          'dateKey' => '219',
          'existingCount' => 1,
          'newCount' => 0
        }
      ])
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:visitor)

      create(:visitor, created_at: Time.new(2021, 8, 7).utc, site_id: site.id)
      create(:visitor, created_at: Time.new(2021, 8, 6).utc, site_id: site.id)
      create(:visitor, created_at: Time.new(2021, 8, 5).utc, site_id: site.id)
      create(:visitor, created_at: Time.new(2021, 7, 5).utc, site_id: site.id)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_visitors_query, variables, user)
    end

    it 'returns the visitors' do
      response = subject['data']['site']['analytics']

      expect(response['visitors']['groupType']).to eq('daily')
      expect(response['visitors']['groupRange']).to eq(7)
      expect(response['visitors']['items']).to match([
        {
          'allCount' => 1,
          'dateKey' => '216',
          'existingCount' => 0,
          'newCount' => 1
        },
        {
          'allCount' => 1,
          'dateKey' => '217',
          'existingCount' => 0,
          'newCount' => 1
        },
        {
          'allCount' => 1,
          'dateKey' => '218',
          'existingCount' => 0,
          'newCount' => 1
        }
      ])
    end
  end
end
