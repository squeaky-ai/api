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
        connected_at: Time.now.to_i * 1000,
        disconnected_at: (Time.now.to_i + 1000) * 1000,
        **args
      )
    end

    def sample(count)
      count.times.map { create }
    end
  end
end
