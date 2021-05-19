# frozen_string_literal: true

module Recordings
  # Websockets don't always send the disconnect signal,
  # which means we need a way of expiring users automatically
  # after a certain amount of time
  class Status
    def initialize(current_user)
      @site_id = current_user[:site_id]
      @viewer_id = current_user[:viewer_id]
      @session_id = current_user[:session_id]
    end

    def active!
      Redis.current.set(key, '1', ex: 60)
    end

    def active?
      Redis.current.get(key) != nil
    end

    def inactive!
      Redis.current.del(key)
    end

    private

    def key
      "#{@site_id}:#{@session_id}:#{@viewer_id}"
    end
  end
end
