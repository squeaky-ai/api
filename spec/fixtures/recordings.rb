# frozen_string_literal: true

require 'securerandom'

module Fixtures
  class Recordings
    def initialize(site)
      @site = site
    end

    def create(args = {})
      Recording.new(
        site: @site,
        session_id: SecureRandom.uuid,
        viewer_id: SecureRandom.uuid,
        locale: 'en-GB',
        page_views: ['/'],
        useragent: Faker::Internet.user_agent,
        viewport_x: 0,
        viewport_y: 0,
        connected_at: DateTime.now,
        disconnected_at: DateTime.now + Faker::Number.between(from: 0 + 500).seconds,
        **args
      )
    end

    def sample(count)
      count.times.map { create }
    end
  end
end
