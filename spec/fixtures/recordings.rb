# frozen_string_literal: true

require 'securerandom'

module Fixtures
  class Recordings
    def initialize(site)
      @site = site
    end

    def create(args = {})
      Recording.new(
        site_id: @site.uuid,
        session_id: SecureRandom.uuid,
        viewer_id: SecureRandom.uuid,
        locale: 'en-GB',
        start_page: '/',
        exit_page: '/',
        useragent: Faker::Internet.user_agent,
        viewport_x: 0,
        viewport_y: 0,
        connected_at: DateTime.now.iso8601,
        disconnected_at: DateTime.now.iso8601,
        **args
      )
    end

    def sample(count)
      count.times.map { create }
    end
  end
end
