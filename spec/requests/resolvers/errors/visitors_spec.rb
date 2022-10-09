# frozen_string_literal: true

require 'rails_helper'

errors_visitors_query = <<-GRAPHQL
  query($site_id: ID!, $error_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      errorDetails(errorId: $error_id) {
        id
        visitors(fromDate: $from_date, toDate: $to_date) {
          items {
            id
          }
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Errors::Visitors, type: :request do
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
      graphql_request(errors_visitors_query, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['site']['errorDetails']
      expect(response).to eq(nil)
    end
  end

  context 'when there are some errors' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:now) { Time.new(2022, 7, 6, 5, 0, 0) }
    let(:recording) { create(:recording, site:, disconnected_at: now.to_i * 1000) }

    before do
      ClickHouse::ErrorEvent.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: recording.id,
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
      graphql_request(errors_visitors_query, variables, user)
    end

    it 'returns the visitors' do
      response = subject['data']['site']['errorDetails']['visitors']
      expect(response['items']).to eq([
        {
          'id' => recording.visitor_id.to_s
        }
      ])
    end
  end
end
