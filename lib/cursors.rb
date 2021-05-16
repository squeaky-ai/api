# frozen_string_literal: true

require 'json'
require 'base64'

# Utility class to encode and decode cusors
# for use in GraphQL pagination
class Cursors
  def self.encode(payload)
    Base64.encode64(payload.to_json).strip
  end

  def self.decode(cursor)
    JSON.parse(Base64.decode64(cursor))
  end
end
