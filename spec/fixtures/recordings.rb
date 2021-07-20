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
        **args
      )
    end

    def sample(count)
      count.times.map { create }
    end
  end
end
