# frozen_string_literal: true

ClickHouse.config do |config|
  config.logger = Rails.logger
  config.assign(Rails.application.config_for('click_house'))
  config.global_params = { mutations_sync: 1 } if Rails.env.test?
end

module ClickHouse
  module Response
    class Factory
      def self.[](faraday)
        body = faraday.body
        # Monkey patch this JSON parse as sometimes it
        # is returning as a string
        # https://github.com/shlima/click_house/issues/17
        body = JSON.parse(body) if body.is_a?(String)

        return body if !body.is_a?(Hash) || !(body.key?('meta') && body.key?('data'))

        ResultSet.new(
          meta: body.fetch('meta'),
          data: body.fetch('data'),
          totals: body['totals'],
          statistics: body['statistcs']
        )
      end
    end
  end
end
