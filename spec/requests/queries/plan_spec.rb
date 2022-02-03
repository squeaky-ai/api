# frozen_string_literal: true

require 'rails_helper'

plan_query = <<-GRAPHQL
  query {
    plans {
      name
      maxMonthlyRecordings
      monthlyPrice {
        GBP
        EUR
        USD
      }
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
          'monthlyPrice' => {
            'GBP' => 0,
            'EUR' => 0,
            'USD' => 0
          }
        },
        {
          'name' => 'Light',
          'maxMonthlyRecordings' => 5000,
          'monthlyPrice' => {
            'GBP' => 38,
            'EUR' => 45,
            'USD' => 50
          }
        },
        {
          'name' => 'Plus',
          'maxMonthlyRecordings' => 25000,
          'monthlyPrice' => {
            'GBP' => 120,
            'EUR' => 145,
            'USD' => 165
          }
        },
        {
          'name' => 'Business',
          'maxMonthlyRecordings' => 50000,
          'monthlyPrice' => {
            'GBP' => 205,
            'EUR' => 245,
            'USD' => 275
          }
        },
        {
          'name' => 'Premium',
          'maxMonthlyRecordings' => 100000,
          'monthlyPrice' => {
            'GBP' => 410,
            'EUR' => 495,
            'USD' => 560
          }
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
