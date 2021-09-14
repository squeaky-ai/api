# frozen_string_literal: true

require 'securerandom'

module Fixtures
  class Recordings
    def initialize(site, visitor)
      @site = site
      @visitor = visitor
    end

    def create(args = {})
      start_at = Time.now.to_i * 1000
      exit_at = (Time.now.to_i + 1000) * 1000

      Recording.create(
        site: @site,
        visitor: @visitor,
        session_id: SecureRandom.uuid,
        locale: 'en-GB',
        useragent: Faker::Internet.user_agent,
        viewport_x: 1920,
        viewport_y: 1080,
        connected_at: start_at,
        disconnected_at: exit_at,
        pages: [Page.new(url: '/', entered_at: start_at, exited_at: exit_at)],
        **args
      )
    end

    def sample(count)
      count.times.map { create }
    end
  end
end
