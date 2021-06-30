# frozen_string_literal: true

require 'securerandom'

module Fixtures
  class Recordings
    def initialize(site)
      @site = site
    end

    def create(args = {})
      now = (Time.now.to_f * 1000).to_i
      connected_at = Faker::Number.between(from: now - 20_000, to: now)

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
        connected_at: connected_at,
        disconnected_at: Faker::Number.between(from: connected_at, to: now),
        **args
      )
    end

    def sample(count)
      count.times.map { create }
    end
  end
end
