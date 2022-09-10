# frozen_string_literal: true

require 'rails_helper'

plan_query = <<-GRAPHQL
  query {
    plans {
      id
      name
      maxMonthlyRecordings
      pricing {
        id
        currency
        amount
        interval
      }
      dataStorageMonths
      support
      responseTimeHours
    }
  }
GRAPHQL

RSpec.describe 'QueryPlan', type: :request do
  it 'returns the plans' do
    response = graphql_request(plan_query, {}, nil)

    expect(response['data']['plans']).to eq(
      [
        {
          'id' => '0',
          'name' => 'Free',
          'maxMonthlyRecordings' => 1000,
          'pricing' => [
            {
              'id' => 'price_1KQvNFLJ9zG7aLW8HEgPtppy',
              'currency' => 'GBP',
              'amount' => 0,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KQvNFLJ9zG7aLW855a0hFk7',
              'currency' => 'EUR',
              'amount' => 0,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KQvNFLJ9zG7aLW8J97ZS43l',
              'currency' => 'USD',
              'amount' => 0,
              'interval' => 'month'
            }
          ],
          'dataStorageMonths' => 6,
          'support' => [
            'Email'
          ],
          'responseTimeHours' => 168
        },
        {
          'id' => '1',
          'name' => 'Light',
          'maxMonthlyRecordings' => 10000,
          'pricing' => [
            {
              'id' => 'price_1KPOV6LJ9zG7aLW852tqylTr',
              'currency' => 'GBP',
              'amount' => 38,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KPOV6LJ9zG7aLW8xMXyFGGr',
              'currency' => 'EUR',
              'amount' => 45,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KPOV6LJ9zG7aLW8tDzfMy0D',
              'currency' => 'USD',
              'amount' => 50,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KrQU8LJ9zG7aLW8I0V3YAv4',
              'currency' => 'GBP',
              'amount' => 365,
              'interval' => 'year'
            },
            {
              'id' => 'price_1KrQT3LJ9zG7aLW8pQwfiYPY',
              'currency' => 'EUR',
              'amount' => 432,
              'interval' => 'year'
            },
            {
              'id' => 'price_1KrQTOLJ9zG7aLW8dKY3BH8e',
              'currency' => 'USD',
              'amount' => 480,
              'interval' => 'year'
            }
          ],
          'dataStorageMonths' => 12,
          'support' => [
            'Email'
          ],
          'responseTimeHours' => 72
        },
        {
          'id' => '2',
          'name' => 'Plus',
          'maxMonthlyRecordings' => 50000,
          'pricing' => [
            {
              'id' => 'price_1KPOVlLJ9zG7aLW88SC9VKKB',
              'currency' => 'GBP',
              'amount' => 120,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KPOVlLJ9zG7aLW892gWiiTU',
              'currency' => 'EUR',
              'amount' => 145,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KPOVlLJ9zG7aLW8bw9qLkLF',
              'currency' => 'USD',
              'amount' => 165,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KrQWKLJ9zG7aLW8LK9YzE4h',
              'currency' => 'GBP',
              'amount' => 1152,
              'interval' => 'year'
            },
            {
              'id' => 'price_1KrQUpLJ9zG7aLW82xVQJCKy',
              'currency' => 'EUR',
              'amount' => 1392,
              'interval' => 'year'
            },
            {
              'id' => 'price_1KrQVrLJ9zG7aLW8WMsmZfkl',
              'currency' => 'USD',
              'amount' => 1584,
              'interval' => 'year'
            }
          ],
          'dataStorageMonths' => 12,
          'support' => [
            'Email'
          ],
          'responseTimeHours' => 24
        },
        {
          'id' => '3',
          'name' => 'Business',
          'maxMonthlyRecordings' => 100000,
          'pricing' => [
            {
              'id' => 'price_1KPOWCLJ9zG7aLW8ylslbe5U',
              'currency' => 'GBP',
              'amount' => 205,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KPOWCLJ9zG7aLW829kU4xrO',
              'currency' => 'EUR',
              'amount' => 245,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KPOWCLJ9zG7aLW8jXWVkVsr',
              'currency' => 'USD',
              'amount' => 275,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KrRvELJ9zG7aLW8oTujLmg4',
              'currency' => 'GBP',
              'amount' => 1968,
              'interval' => 'year'
            },
            {
              'id' => 'price_1KrRuKLJ9zG7aLW8n2g9Fue9',
              'currency' => 'EUR',
              'amount' => 2352,
              'interval' => 'year'
            },
            {
              'id' => 'price_1KrRudLJ9zG7aLW8q3rQMsp3',
              'currency' => 'USD',
              'amount' => 2640,
              'interval' => 'year'
            }
          ],
          'dataStorageMonths' => 12,
          'support' => [
            'Email',
            'Chat'
          ],
          'responseTimeHours' => 24
        },
        {
          'id' => '4',
          'name' => 'Premium',
          'maxMonthlyRecordings' => 200000,
          'pricing' => [
            {
              'id' => 'price_1KPOWhLJ9zG7aLW8J2T8etAP',
              'currency' => 'GBP',
              'amount' => 410,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KPOWhLJ9zG7aLW8lDyXxWeS',
              'currency' => 'EUR',
              'amount' => 495,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KPOWhLJ9zG7aLW8RHpK5q60',
              'currency' => 'USD',
              'amount' => 560,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KrRxeLJ9zG7aLW8Hb8iahdY',
              'currency' => 'GBP',
              'amount' => 3936,
              'interval' => 'year'
            },
            {
              'id' => 'price_1KrRwbLJ9zG7aLW8VMNu37Bb',
              'currency' => 'EUR',
              'amount' => 4752,
              'interval' => 'year'
            },
            {
              'id' => 'price_1KrRxHLJ9zG7aLW8GM1b8mTH',
              'currency' => 'USD',
              'amount' => 5376,
              'interval' => 'year'
            }
          ],
          'dataStorageMonths' => 12,
          'support' => [
            'Email',
            'Chat'
          ],
          'responseTimeHours' => 24
        },
        {
          'id' => '5',
          'name' => 'Enterprise Tier 1',
          'maxMonthlyRecordings' => 250000,
          'pricing' => [
            {
              'id' => 'price_1KrS2KLJ9zG7aLW8AY5dAe2S',
              'currency' => 'GBP',
              'amount' => 830,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KrS2KLJ9zG7aLW8ce9pbVs4',
              'currency' => 'EUR',
              'amount' => 995,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KrS2KLJ9zG7aLW86h5GNFoR',
              'currency' => 'USD',
              'amount' => 1125,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KrS2KLJ9zG7aLW87ZLHGqgI',
              'currency' => 'GBP',
              'amount' => 7968,
              'interval' => 'year'
            },
            {
              'id' => 'price_1KrS2KLJ9zG7aLW8pkQg5f4d',
              'currency' => 'EUR',
              'amount' => 9552,
              'interval' => 'year'
            },
            {
              'id' => 'price_1KrS2KLJ9zG7aLW821CsgH60',
              'currency' => 'USD',
              'amount' => 10800,
              'interval' => 'year'
            }
          ],
          'dataStorageMonths' => -1,
          'support' => [
            'Email',
            'Chat',
            'Phone'
          ],
          'responseTimeHours' => 0
        },
        {
          'id' => '6',
          'name' => 'Enterprise Tier 2',
          'maxMonthlyRecordings' => 500000,
          'pricing' => [
            {
              'id' => 'price_1KrS70LJ9zG7aLW8Pnf4Wt8N',
              'currency' => 'GBP',
              'amount' => 2085,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KrS70LJ9zG7aLW8U5YviqRa',
              'currency' => 'EUR',
              'amount' => 2500,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KrS70LJ9zG7aLW8pZ1VFyah',
              'currency' => 'USD',
              'amount' => 2830,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KrS70LJ9zG7aLW8m1sgzDWf',
              'currency' => 'GBP',
              'amount' => 20016,
              'interval' => 'year'
            },
            {
              'id' => 'price_1KrS70LJ9zG7aLW8G8cD9OUn',
              'currency' => 'EUR',
              'amount' => 24000,
              'interval' => 'year'
            },
            {
              'id' => 'price_1KrS70LJ9zG7aLW8NuJwC1aV',
              'currency' => 'USD',
              'amount' => 27168,
              'interval' => 'year'
            }
          ],
          'dataStorageMonths' => -1,
          'support' => [
            'Email',
            'Chat',
            'Phone'
          ],
          'responseTimeHours' => 0
        },
        {
          'id' => '7',
          'name' => 'Enterprise Tier 3',
          'maxMonthlyRecordings' => 750000,
          'pricing' => [
            {
              'id' => 'price_1KrSCdLJ9zG7aLW8mPrReLYX',
              'currency' => 'GBP',
              'amount' => 4170,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KrSCdLJ9zG7aLW8QyHZPXsr',
              'currency' => 'EUR',
              'amount' => 5000,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KrSCdLJ9zG7aLW8rQePlePo',
              'currency' => 'USD',
              'amount' => 5650,
              'interval' => 'month'
            },
            {
              'id' => 'price_1KrSCdLJ9zG7aLW8E3qnKn6T',
              'currency' => 'GBP',
              'amount' => 40032,
              'interval' => 'year'
            },
            {
              'id' => 'price_1KrSCdLJ9zG7aLW8kPZnksMP',
              'currency' => 'EUR',
              'amount' => 48000,
              'interval' => 'year'
            },
            {
              'id' => 'price_1KrSCdLJ9zG7aLW8CXq63zYe',
              'currency' => 'USD',
              'amount' => 54240,
              'interval' => 'year'
            }
          ],
          'dataStorageMonths' => -1,
          'support' => [
            'Email',
            'Chat',
            'Phone'
          ],
          'responseTimeHours' => 0
        }
      ]
    )
  end
end