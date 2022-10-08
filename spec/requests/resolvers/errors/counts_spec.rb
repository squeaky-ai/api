# frozen_string_literal: true

require 'rails_helper'

errors_counts_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      errorsCounts(fromDate: $from_date, toDate: $to_date) {
        groupType
        groupRange
        items {
          dateKey
          count
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Errors::Counts, type: :request do
  context 'when there are no errors' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      today = Time.now.strftime('%Y-%m-%d')

      variables = { 
        site_id: site.id,
        from_date: today, 
        to_date: today 
      }
      graphql_request(errors_counts_query, variables, user)
    end

    it 'returns an empty list' do
      response = subject['data']['site']['errorsCounts']
      expect(response).to eq(
        'groupRange' => 24,
        'groupType' => 'hourly',
        'items' => []
      )
    end
  end

  context 'when there are some errors' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:now) { Time.new(2022, 7, 6, 5, 0, 0) }

    before do
      ClickHouse::ErrorEvent.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: 0,
          message: 'Error: Oh no!',
          timestamp: now.to_i * 1000
        }
      end
    end

    subject do
      today = now.strftime('%Y-%m-%d')

      variables = { 
        site_id: site.id,
        from_date: today, 
        to_date: today 
      }
      graphql_request(errors_counts_query, variables, user)
    end

    it 'returns the events' do
      response = subject['data']['site']['errorsCounts']

      expect(response).to eq(
        'groupRange' => 24,
        'groupType' => 'hourly',
        'items' => [
          {
            'count' => 1, 
            'dateKey' => '00'
          }
        ]
      )
    end
  end
end
