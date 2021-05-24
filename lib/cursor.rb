# frozen_string_literal: true

require 'json'
require 'base64'

# Utility class to encode and decode cusors
# for use in GraphQL pagination
class Cursor
  def self.encode(payload)
    return nil unless payload

    payload = payload.to_json unless payload.is_a?(String)

    Base64.encode64(payload).strip
  end

  def self.decode(cursor)
    return nil unless cursor

    JSON.parse(Base64.decode64(cursor))
  rescue StandardError => e
    Rails.logger.warn e
    nil
  end
end
