# frozen_string_literal: true

module Webhooks
  class MollieController < ApplicationController
    def index
      Rails.logger.info params
      render json: { success: true }
    end
  end
end
