# frozen_string_literal: true

class PingController < ApplicationController
  def index
    Redis.current.ping
    ActiveRecord::Base.connection.verify!
    render plain: 'PONG'
  rescue StandardError => e
    logger.error(e)
    render plain: 'NOT PONG!', status: 500
  end
end
