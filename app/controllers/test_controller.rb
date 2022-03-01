# frozen_string_literal: true

class TestController < ApplicationController
  before_action :restrict_to_development

  def create_user
    user = User.create(create_user_params)
    user.save
    user.confirm

    render json: user
  end

  def destroy_user
    user = User.find_by(destroy_user_params)
    user&.destroy

    render json: ''
  end

  protected

  def restrict_to_development
    head(:bad_request) if Rails.env.production?
  end

  private

  def create_user_params
    params.permit(:email, :password)
  end

  def destroy_user_params
    params.permit(:email)
  end
end
