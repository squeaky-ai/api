# frozen_string_literal: true

class FeedbackController < ApplicationController
  def index
    site = Site.find_by(uuid: site_uuid)

    # Always return this for sites that don't exist as it
    # stops people from being able to guess which sites
    # exist by spamming different uuids
    if site&.feedback.nil?
      Rails.logger.info "Site #{site&.id || '-none-'} has no feedback"
      return render json: { nps_enabled: false, sentiment_enabled: false }
    end

    render json: site.feedback.serializable_hash(except: %i[id created_at updated_at site_id])
  end

  private

  def site_uuid
    params.require(:site_id)
  end
end
