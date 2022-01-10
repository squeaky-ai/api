# frozen_string_literal: true

require 'rails_helper'

plan_query = <<-GRAPHQL
  query {
    plans {
      maxMonthlyRecordings
      monthlyPrice
    }
  }
GRAPHQL

RSpec.describe 'QueryPlan', type: :request do
  it 'returns the plans' do
    response = graphql_request(plan_query, {}, nil)

    expect(response['data']['plans']).to match_array(
      [
        {
          'maxMonthlyRecordings' => 500,
          'monthlyPrice' => 0
        },
        {
          'maxMonthlyRecordings' => 5000,
          'monthlyPrice' => 50
        },
        {
          'maxMonthlyRecordings' => 25000,
          'monthlyPrice' => 150
        },
        {
          'maxMonthlyRecordings' => 50000,
          'monthlyPrice' => 250
        },
        {
          'maxMonthlyRecordings' => 100000,
          'monthlyPrice' => 500
        }
      ]
    )
  end
end
