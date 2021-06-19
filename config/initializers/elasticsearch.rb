# frozen_string_literal: true

require 'elasticsearch'

SearchClient = Elasticsearch::Client.new(
  url: Rails.configuration.elasticsearch['url'],
  retry_on_failure: 5,
  request_timeout: 30
)
