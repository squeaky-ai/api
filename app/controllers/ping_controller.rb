# frozen_string_literal: true

class PingController < ApplicationController
  def index
    ActiveRecord::Base.connection.verify!
    Cache.redis.ping
    ClickHouse.connection.ping
    render plain: 'PONG'
  rescue StandardError => e
    logger.fatal(e)
    render plain: 'NOT PONG!', status: :internal_server_error
  end
end
