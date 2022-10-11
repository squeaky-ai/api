# frozen_string_literal: true

module Sites
  class HeatmapsController < ApplicationController
    def cursors # rubocop:disable Metrics/AbcSize
      site = SiteService.find_by_id(current_user, cursor_params[:site_id])
      return render status: :unauthorized unless site

      items = HeatmapsService.new(
        site_id: cursor_params[:site_id],
        from_date: cursor_params[:from_date],
        to_date: cursor_params[:to_date],
        page_url: cursor_params[:page_url],
        device: cursor_params[:device]
      )

      render json: Oj.dump(items.cursors.to_a)
    end

    private

    def cursor_params
      params.permit(:site_id, :from_date, :to_date, :page_url, :device)
    end
  end
end
