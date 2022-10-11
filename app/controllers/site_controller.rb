# frozen_string_literal: true

class SiteController < ApplicationController
  before_action :require_site

  private

  def require_site
    @site = SiteService.find_by_id(current_user, cursor_params[:site_id])
    # Not the correct error type
    raise ActionController::BadRequest unless @site
  end
end
