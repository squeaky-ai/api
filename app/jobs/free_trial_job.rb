# frozen_string_literal: true

class FreeTrialJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(site_id)
    site = Site.find_by(id: site_id)

    return unless site
    return unless site.plan.free?

    site.plan.end_free_trial!
  end
end
