# typed: false
# frozen_string_literal: true

class EventTrackingJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(*args)
    client = SqueakyClient.new
    client.add_event(**args.first)
  rescue HTTParty::Error => e
    Rails.logger.error("Failed to send Squeaky tracking event - #{e}")
  end
end
