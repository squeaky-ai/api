# typed: false
# frozen_string_literal: true

require 'rails_helper'

errors_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      errors(fromDate: $from_date, toDate: $to_date) {
        items {
          id
          message
          errorCount
          recordingCount
          lastOccurance {
            iso8601
          }
        }
        pagination {
          pageSize
          total
          sort
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Errors::Errors, type: :request do
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
      graphql_request(errors_query, variables, user)
    end

    it 'returns an empty list' do
      response = subject['data']['site']['errors']

      expect(response['items']).to eq([])
      expect(response['pagination']).to eq(
        'pageSize' => 25,
        'total' => 0,
        'sort' => 'error_count__desc'
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
      graphql_request(errors_query, variables, user)
    end

    it 'returns the events' do
      response = subject['data']['site']['errors']

      expect(response['items']).to match_array([
        {
          'id' => 'RXJyb3I6IE9oIG5vIQ==',
          'errorCount' => 1,
          'lastOccurance' => {
            'iso8601' => '2022-07-06T04:00:00Z'
          },
          'message' => 'Error: Oh no!',
          'recordingCount' => 1
        }
      ])
      expect(response['pagination']).to eq(
        'pageSize' => 25,
        'total' => 1,
        'sort' => 'error_count__desc'
      )
    end
  end
end
