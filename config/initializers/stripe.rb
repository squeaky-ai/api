# typed: false
# frozen_string_literal: true

require 'stripe'

Stripe.api_key = ENV.fetch(
  'STRIPE_API_KEY',
  'sk_test_51KPOB2LJ9zG7aLW8Nc9J3oNLUjkTAzCgr6h6HYBuji45OUg5MA890cYhj4EuRooUeRW8mmityJbfUuZQ2uKb34fn006kDIrkWF'
)
