# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from ActionController::RoutingError, with: :not_found

  def not_found
    render json: { error: 'Not found' }, status: 404
  end
end
