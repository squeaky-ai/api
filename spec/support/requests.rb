# frozen_string_literal: true

module Requests
  module JsonHelpers
    def json_body
      JSON.parse(response.body)
    end
  end
end

RSpec.configure do |config|
  config.include Requests::JsonHelpers, type: :controller
end
