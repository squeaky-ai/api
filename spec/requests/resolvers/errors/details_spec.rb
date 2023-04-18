# frozen_string_literal: true

require 'rails_helper'

errors_details_query = <<-GRAPHQL
  query($site_id: ID!, $error_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      error(errorId: $error_id, fromDate: $from_date, toDate: $to_date) {
        details {
          id
          message
          stack
          pages
          filename
          lineNumber
          colNumber
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Errors::Details, type: :request do
  context 'when there is no error' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:now) { Time.new(2022, 7, 6, 5, 0, 0) }

    subject do
      today = now.strftime('%Y-%m-%d')

      variables = { 
        site_id: site.id,
        error_id: 'sdfdsfdsdsf',
        from_date: today,
        to_date: today
      }
      graphql_request(errors_details_query, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['site']['error']['details']
      expect(response).to eq(nil)
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
          col_number: 5,
          line_number: 2,
          filename: 'test.js',
          url: '/',
          message: 'Error: Oh no!',
          stack: 'Not good!',
          timestamp: now.to_i * 1000
        }
      end
    end

    subject do
      today = now.strftime('%Y-%m-%d')

      variables = { 
        site_id: site.id,
        error_id: Base64.encode64('Error: Oh no!'),
        from_date: today,
        to_date: today
      }
      graphql_request(errors_details_query, variables, user)
    end

    it 'returns the details' do
      response = subject['data']['site']['error']['details']
      expect(response).to eq(
        'id' => 'RXJyb3I6IE9oIG5vIQ==',
        'colNumber' => 5,
        'filename' => 'test.js',
        'lineNumber' => 2,
        'message' => 'Error: Oh no!',
        'pages' => ['/'],
        'stack' => 'Not good!'
      )
    end
  end
end
