# frozen_string_literal: true

require 'rails_helper'

plan_query = <<-GRAPHQL
  query {
    plans {
      name
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
          'name' => 'Free',
          'maxMonthlyRecordings' => 500,
          'monthlyPrice' => 0
        },
        {
          'name' => 'Light',
          'maxMonthlyRecordings' => 5000,
          'monthlyPrice' => 50
        },
        {
          'name' => 'Plus',
          'maxMonthlyRecordings' => 25000,
          'monthlyPrice' => 150
        },
        {
          'name' => 'Business',
          'maxMonthlyRecordings' => 50000,
          'monthlyPrice' => 250
        },
        {
          'name' => 'Premium',
          'maxMonthlyRecordings' => 100000,
          'monthlyPrice' => 500
        },
        {
          'name' => 'Unlimited',
          'maxMonthlyRecordings' => nil,
          'monthlyPrice' => nil
        }
      ]
    )
  end
end
