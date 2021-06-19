# frozen_string_literal: true

require 'elasticsearch'

SearchClient = Elasticsearch::Client.new(
  url: ENV.fetch('ELASTICSEARCH_URL', 'http://localhost:9200'),
  retry_on_failure: 5,
  request_timeout: 30
)
