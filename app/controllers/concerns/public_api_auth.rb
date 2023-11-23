# frozen_string_literal: true

module PublicApiAuth
  extend ActiveSupport::Concern

  included do
    before_action :authorize
  end

  private

  def authorize
    return render json: { error: 'Forbidden' }, status: :forbidden unless api_key

    render json: { error: 'Forbidden' }, status: :forbidden unless site
  end

  def api_key
    request.headers['X-SQUEAKY-API-KEY']
  end

  def site
    @site ||= Site.find_by_api_key(api_key)
  end
end
