# frozen_string_literal: true

require 'httparty'

class SqueakyClient
  include HTTParty

  base_uri 'https://squeaky.ai'

  def add_event(name:, user_id:, data:)
    body = {
      name:,
      user_id:,
      data: data.to_json
    }.to_json

    self.class.post('/api/events', body:, headers:, timeout:)
  end

  private

  def headers
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'X-SQUEAKY-API-KEY' => ENV.fetch('SQUEAKY_API_KEY')
    }
  end

  def timeout
    5
  end
end
