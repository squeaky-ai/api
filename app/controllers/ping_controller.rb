# frozen_string_literal: true

# A controller that exposes a ping endpoint so that the
# ALB can check the app is healthy. After a few failed
# attemps the app will be killed and restarted
class PingController < ApplicationController
  def index
    ActiveRecord::Base.connection.verify!
    render plain: 'PONG'
  rescue StandardError => e
    logger.error(e)
    render plain: 'NOT PONG!', status: 500
  end
end
