# typed: false
# frozen_string_literal: true

class ApplicationController < ActionController::API
  def not_found
    render json: { error: 'Not found' }, status: :not_found
  end
end
