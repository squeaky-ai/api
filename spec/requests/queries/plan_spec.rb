# frozen_string_literal: true

require 'rails_helper'

plan_query = <<-GRAPHQL
  query {
    plans {
      name
      maxMonthlyRecordings
      pricing {
        id
        currency
        amount
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
          'pricing' => nil
        },
        {
          'name' => 'Light',
          'maxMonthlyRecordings' => 5000,
          'pricing' => [
            {
              'id' => 'price_1KPOV6LJ9zG7aLW852tqylTr',
              'currency' => 'GBP',
              'amount' => 38
            },
            {
              'id' => 'price_1KPOV6LJ9zG7aLW8xMXyFGGr',
              'currency' => 'EUR',
              'amount' => 45
            },
            {
              'id' => 'price_1KPOV6LJ9zG7aLW8tDzfMy0D',
              'currency' => 'USD',
              'amount' => 50
            }
          ]
        },
        {
          'name' => 'Plus',
          'maxMonthlyRecordings' => 25000,
          'pricing' => [
            {
              'id' => 'price_1KPOVlLJ9zG7aLW88SC9VKKB',
              'currency' => 'GBP',
              'amount' => 120
            },
            {
              'id' => 'price_1KPOVlLJ9zG7aLW892gWiiTU',
              'currency' => 'EUR',
              'amount' => 145
            },
            {
              'id' => 'price_1KPOVlLJ9zG7aLW8bw9qLkLF',
              'currency' => 'USD',
              'amount' => 165
            }
          ]
        },
        {
          'name' => 'Business',
          'maxMonthlyRecordings' => 50000,
          'pricing' => [
            {
              'id' => 'price_1KPOWCLJ9zG7aLW8ylslbe5U',
              'currency' => 'GBP',
              'amount' => 205
            },
            {
              'id' => 'price_1KPOWCLJ9zG7aLW829kU4xrO',
              'currency' => 'EUR',
              'amount' => 245
            },
            {
              'id' => 'price_1KPOWCLJ9zG7aLW8jXWVkVsr',
              'currency' => 'USD',
              'amount' => 275
            }
          ]
        },
        {
          'name' => 'Premium',
          'maxMonthlyRecordings' => 100000,
          'pricing' => [
            {
              'id' => 'price_1KPOWhLJ9zG7aLW8J2T8etAP',
              'currency' => 'GBP',
              'amount' => 410
            },
            {
              'id' => 'price_1KPOWhLJ9zG7aLW8lDyXxWeS',
              'currency' => 'EUR',
              'amount' => 495
            },
            {
              'id' => 'price_1KPOWhLJ9zG7aLW8RHpK5q60',
              'currency' => 'USD',
              'amount' => 560
            }
          ]
        },
        {
          'name' => 'Unlimited',
          'maxMonthlyRecordings' => nil,
          'pricing' => nil
        }
      ]
    )
  end
end
