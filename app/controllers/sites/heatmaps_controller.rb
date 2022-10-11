# frozen_string_literal: true

module Sites
  class HeatmapsController < SiteController
    def cursors
      render json: Oj.dump(heatmaps_instance.cursors.to_a)
    end

    def click_counts
      render json: Oj.dump(heatmaps_instance.click_counts.to_a)
    end

    def click_positions
      render json: Oj.dump(heatmaps_instance.click_positions.to_a)
    end

    def scrolls
      render json: Oj.dump(heatmaps_instance.scrolls.to_a)
    end

    private

    def heatmaps_instance
      @heatmaps_instance ||= HeatmapsService.new(
        site_id: @site.id,
        from_date: cursor_params[:from_date],
        to_date: cursor_params[:to_date],
        page_url: cursor_params[:page_url],
        device: cursor_params[:device]
      )
    end

    def cursor_params
      params.permit(:site_id, :from_date, :to_date, :page_url, :device)
    end
  end
end
