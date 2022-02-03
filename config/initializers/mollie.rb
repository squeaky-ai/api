# frozen_string_literal: true

Mollie::Client.configure do |config|
  config.api_key = ENV.fetch('MOLLIE_API_KEY', 'test_FWV6RGKCaCFdAnvrp9ykGpTSQRHtPH')
end
